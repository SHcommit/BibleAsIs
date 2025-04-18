//
//  BibleNoteReactor+NoteStream.swift
//  BibleNoteFeature
//
//  Created by 양승현 on 3/23/25.
//

import RxSwift
import ReactorKit
import Foundation
import DomainEntity
import CoreInterface

extension BibleNoteReactor {
  static func sendUnexpectedErrorStream(_ observer: AnyObserver<Mutation>, with errorMsg: String) {
    observer.onNext(.unexpectedError(errorMsg))
    observer.onNext(.unexpectedError(""))
  }
  
  func sendUnexpectedErrorObservable(with errorMsg: String) -> Observable<Mutation> {
    return Observable.concat([
      .just(.unexpectedError(errorMsg)),
      .just(.unexpectedError(""))
    ])
  }
  
  func fetchNoteStream() -> Observable<Mutation> {
    return Observable.create { [weak self] observer in
      guard let self else {
        Self.sendUnexpectedErrorStream(observer, with: CommonError.referenceDeallocated.localizedDescription)
        return Disposables.create()
      }
      
      noteUseCase.fetchNotes(for: initialState.bibleVerse.id, page: 1, pageSize: 1) { result in
        switch result {
        case .success((let notes, _)):
          if let note = notes.first {
            observer.onNext(.bibleNoteFetched(note))
          } else {
            observer.onNext(.firstTimeToWriteNote(true))
          }
        case .failure(let failure):
          Self.sendUnexpectedErrorStream(observer, with: failure.localizedDescription)
        }
        observer.onCompleted()
      }
      return Disposables.create()
    }
  }
  
  func updateNoteStream(with modifiedNoteContent: String) -> Observable<Mutation> {
    guard var modifiedNote = currentState.bibleNote else {
      return sendUnexpectedErrorObservable(with: CommonError.referenceDeallocated.localizedDescription)
    }
    modifiedNote.text = modifiedNoteContent
    
    let currentNoteHash = textHasher.toHash(of: modifiedNoteContent)
    let modified = !textHasher.compare(lhs: currentNoteHash, rhs: initialNoteHash)
    guard modified else {
      return sendUnexpectedErrorObservable(with: "⚠️ 노트가 변경되지 않았습니다.\n내용을 입력한 후 다시 시도해주세요.")
    }
    
    if modifiedNoteContent.isEmpty {
      guard modified else {
        return sendUnexpectedErrorObservable(with: "⚠️ 노트를 작성한 후 저장해주세요.")
      }
    }
    
    modifiedNote.date = Date()
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      noteUseCase.updateNote(modifiedNote) {  processHasSucceed in
        switch processHasSucceed {
        case .success(let success):
          if success {
            observer.onNext(.noteModified(modifiedNote))
            observer.onNext(.noteModifiedCompletion(true))
          } else {
            Self.sendUnexpectedErrorStream(observer, with: "❗ 문제가 발생해 노트를 업데이트 하지 못했습니다.")
          }
        case .failure(let failure):
          let errMsg = "❗ 문제가 발생해 노트를 업데이트 하지 못했습니다.\n (error: \(failure.localizedDescription))"
          Self.sendUnexpectedErrorStream(observer, with: errMsg)
        }
        observer.onCompleted()
      }
      return Disposables.create()
    }
  }
  
  func noteDeleteStream() -> Observable<Mutation> {
    return Observable.create { [weak self] observer in
      guard let self, let curNote = currentState.bibleNote else {
        Self.sendUnexpectedErrorStream(observer, with: CommonError.referenceDeallocated.localizedDescription)
        return Disposables.create()
      }
      
      noteUseCase.deleteNote(curNote.noteId) { result in
        switch result {
        case .success:
          observer.onNext(.noteDeleted)
          observer.onNext(.noteModifiedCompletion(true))
        case .failure(let failure):
          Self.sendUnexpectedErrorStream(observer, with: failure.localizedDescription)
        }
        observer.onCompleted()
      }
      return Disposables.create()
    }
  }
  
  func noteSaveStream(with noteContent: String) -> Observable<Mutation> {
    let currentNoteHash = textHasher.toHash(of: noteContent)
    let modified = !textHasher.compare(lhs: currentNoteHash, rhs: initialNoteHash)
    guard modified else {
      return sendUnexpectedErrorObservable(with: "⚠️ 노트가 저장되지 않았습니다.\n내용을 입력한 후 다시 시도해주세요.")
    }
    
    if noteContent.isEmpty {
      guard modified else {
        return sendUnexpectedErrorObservable(with: "⚠️ 노트를 작성한 후 저장해주세요.")
      }
    }
    
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      let verse = currentState.bibleVerse
      let range = currentState.range
      noteUseCase.addNote(
        verseId: verse.id,
        text: noteContent,
        range: range
      ) { result in
        switch result {
        case .success(let noteId):
          if let noteId {
            let newNote = BibleNote(
              noteId: noteId, verseId: verse.id,
              text: noteContent, range: range, date: Date())
            observer.onNext(.noteModified(newNote))
            observer.onNext(.noteModifiedCompletion(true))
          } else {
            Self.sendUnexpectedErrorStream(observer, with: "❗ 에러가 발생해 노트 저장에 실패했습니다.")
          }
        case .failure(let failure):
          Self.sendUnexpectedErrorStream(observer, with: failure.localizedDescription)
        }
        observer.onCompleted()
      }
      return Disposables.create()
    }
  }
}
