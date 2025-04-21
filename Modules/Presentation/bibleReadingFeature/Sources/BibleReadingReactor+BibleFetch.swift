//
//  BibleReadingReactor+BibleFetch.swift
//  BibleContentFeature
//
//  Created by 양승현 on 3/17/25.
//

import RxSwift
import ReactorKit
import Foundation
import DomainEntity
import DesignSystemItems

extension BibleReadingReactor {
  // MARK: - AsObservable
  func fetchBibleVersesAsObservable() -> Observable<[BibleVerse]> {
    Observable.create { [weak self] observer in
      guard let self else {
        observer.onError(CommonError.referenceDeallocated); return Disposables.create()
      }
      bibleRepository.fetchBibleVerses(
        for: currentReadingEntryItem.bibleBook,
        chapter: currentReadingEntryItem.chapter
      ) { result in
        switch result {
        case .success(let verses):
          observer.onNext(verses)
          observer.onCompleted()
        case .failure(let error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
  
  // MARK: - Stream
  func fetchBibleVerseStream() -> Observable<Mutation> {
    typealias highlightItem = BibleVerseHighlightItem
    
    let bibleVerseAsObservable: Observable<Mutation> = fetchBibleVersesAsObservable()
      .flatMap { [weak self] bibleVerses in
        return Observable.from(bibleVerses)
          .concatMap { [weak self] bibleVerse -> Observable<BibleVerseItem> in
            guard let self else { return .empty() }
            let heartStatusObservable = makeHeartStatusFetchObservable(for: bibleVerse.id)
            let highlightObservable = makeHighlightsFetchObservable(for: bibleVerse.id)
            let noteObservable = makeNoteFetchObservable(for: bibleVerse.id, page: 0, pageSize: 10)
            let fontSize = fontSystemSettingsFetchUseCase.fetchFontSize()
            return Observable
              .zip(heartStatusObservable, highlightObservable, noteObservable)
              .map { heart, highlights, note -> BibleVerseItem in
                let bibleReference = BibleReference(
                  book: bibleVerse.book,
                  chapter: bibleVerse.chapter,
                  verse: bibleVerse.verse)
                
                var item = BibleVerseItem(
                  reference: bibleReference,
                  verseContent: bibleVerse.content,
                  isOnHeart: heart,
                  highlights: highlights.map {
                    highlightItem(id: $0.id, range: $0.range, colorIndex: .init(rawValue: $0.colorIndex) ?? .pink)
                  },
                  fontSize: fontSize)
                if let note {
                  item.note = BibleVerseNoteItem(noteId: note.noteId, range: note.range, text: note.text)
                }
                return item
              }
          }.toArray()
          .map { Mutation.bibleVersesSet($0) }
      }
    
    let bookTitleStream = Observable.just(Mutation.bookChapterVerseNameSet(fetchBookChapterText()))
    return Observable.concat([
      Observable.merge(bibleVerseAsObservable, bookTitleStream),
      Observable.just(Mutation.shouldReload(true)),
      Observable.just(Mutation.shouldReload(false))
    ])
  }
}
