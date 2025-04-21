//
//  BibleReadingReactor+Note.swift
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
  func makeNoteFetchObservable(for verseId: Int, page: Int, pageSize: Int) -> Observable<BibleNote?> {
    return Observable<BibleNote?>.create { [weak self] noteObserver in
      guard let self else { noteObserver.onError(CommonError.referenceDeallocated)
        return Disposables.create()
      }
      
      bibleRepository.fetchNotes(for: verseId, page: page, pageSize: pageSize) { result in
        switch result {
        case .success(let notes):
          if let firstNote = notes.notes.first {
            noteObserver.onNext(firstNote)
          } else {
            noteObserver.onNext(nil)
          }
          noteObserver.onCompleted()
        case .failure(let error):
          noteObserver.onError(error)
        }
      }
      return Disposables.create()
    }
  }

  func deleteNoteAsObservable(for noteId: Int) -> Observable<Void> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      bibleRepository.deleteNote(noteId) { result in
        switch result {
        case .success:
          observer.onNext(())
          observer.onCompleted()
        case .failure(let error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
  
  // MARK: - Stream
  func deleteNoteStream(with index: Int) -> Observable<Mutation> {
    guard let noteId = currentState.bibleVerses[index].note?.noteId else {
      assertionFailure("노트 삭제 실패. index: \(index), \(currentState.bibleVerses[index])")
      return .just(Mutation.error("삭제할 노트 아이디를 식별하지 못했습니다\n잠시 후에 다시 시도해주세요"))
    }
    return Observable.concat([
      deleteNoteAsObservable(for: noteId).map { Mutation.noteRemove(index: index) },
      .just(Mutation.noteUpdatedCompletion(true)),
      .just(Mutation.noteUpdatedCompletion(false))
    ])
  }
  
  func appendNoteStream(withIndex index: Int, bibleNote: BibleNote) -> Observable<Mutation> {
    let noteItem = BibleVerseNoteItem(noteId: bibleNote.noteId, range: bibleNote.range, text: bibleNote.text)
    return Observable.concat([
      .just(.noteAppend(index: index, noteItem)),
      .just(Mutation.noteUpdatedCompletion(true)),
      .just(Mutation.noteUpdatedCompletion(false))
    ])
  }
}
