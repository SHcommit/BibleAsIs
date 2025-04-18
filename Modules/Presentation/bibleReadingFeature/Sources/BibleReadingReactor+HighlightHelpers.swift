//
//  BibleReadingReactor+HighlightHelpers.swift
//  BibleContentFeature
//
//  Created by 양승현 on 3/17/25.
//

import RxSwift
import Foundation
import DomainEntity
import DesignSystemItems

extension BibleReadingReactor {
  // MARK: - AsObservable
  func addHighlightAsObservable(
    verseId: Int,
    range: NSRange,
    colorIndex: HighlightColorIndex
  ) -> Observable<BibleVerseHighlightItem> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      bibleRepository.addHighlight(verseId: verseId, range: range, colorIndex: colorIndex.rawValue) { result in
        switch result {
        case .success(let highlightId):
          if let highlightId {
            let item = BibleVerseHighlightItem(id: highlightId, range: range, colorIndex: colorIndex)
            observer.onNext(item)
            observer.onCompleted()
          } else {
            observer.onError(NSError(
              domain: "com.presentation.HighlightAppend",
              code: 1000, userInfo: [NSLocalizedDescriptionKey: "Fail to save highlight."]))
          }
        case .failure(let failure):
          observer.onError(failure)
        }
      }
      return Disposables.create()
    }
  }
    
  func makeHighlightsFetchObservable(for verseId: Int) -> Observable<[BibleHighlight]> {
    return Observable<[BibleHighlight]>.create { [weak self] highlightObserver in
      guard let self else { highlightObserver.onError(CommonError.referenceDeallocated)
        return Disposables.create()
      }
      
      bibleRepository.fetchHighlights(for: verseId) { result in
        switch result {
        case .success(let highlights):
          highlightObserver.onNext(highlights)
          highlightObserver.onCompleted()
        case .failure(let error):
          highlightObserver.onError(error)
        }
      }
      return Disposables.create()
    }
  }
  
  // MARK: - Stream
  func deleteHighlightStream(index: Int, id: Int) -> Observable<Mutation> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      bibleRepository.deleteHighlight(id) { result in
        switch result {
        case .success:
          observer.onNext(Mutation.highlightRemove(index: index, id: id))
          observer.onCompleted()
        case .failure(let failure):
          observer.onError(failure)
        }
      }
      return Disposables.create()
    }
  }

  func addHighlightStream(index: Int, range: NSRange, colorIndex: HighlightColorIndex) -> Observable<Mutation> {
    let verse = currentState.bibleVerses[index]
    let identifier = verse.verseId
    return addHighlightAsObservable(
      verseId: identifier, range: range, colorIndex: colorIndex
    ).map { Mutation.highlightAppend(index: index, $0) }
  }
}
