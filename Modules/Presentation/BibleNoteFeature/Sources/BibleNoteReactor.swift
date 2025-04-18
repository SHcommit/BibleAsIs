//
//  BibleNoteReactor.swift
//  BibleNoteFeature
//
//  Created by 양승현 on 3/7/25.
//

import Common
import RxSwift
import ReactorKit
import Foundation
import DomainEntity
import CoreInterface
import DomainInterface

/// 해쉬값이 없으면 빈문자열 해쉬화 하지말고 빈 문자열 반환하자.
public final class BibleNoteReactor: Reactor {
  public enum Action {
    case refresh
    
    /// 지금은 텍스트만 바꾸는 거로 하자. 텍스트 바꾸면 Date 시간 최신으로 변경
    case noteContentModifiy(String)
    case noteDelete
    case noteSave(String)
  }
  
  public enum Mutation {
    case none
    case bibleNoteFetched(BibleNote)
    
    case noteModified(BibleNote)
    case noteDeleted
    case noteModifiedCompletion(Bool)
    
    case hasNoteFetched(Bool)
    /// 처음 들어왔을 때!
    case firstTimeToWriteNote(Bool)
    
    /// 노트 삭제나 수정 에러나면
    case unexpectedError(String)
  }
  
  public struct State {
    /// note가 없다는 것은 노트를 처음 작성하는것임.
    /// 그럴땐 range, verse만 있음
    /// 노트가 있다면 여기에 저장됨
    public var bibleNote: BibleNote?
    /// 그러나 노트 id를 받는다는 것은 note 가 있다는것임
    /// bibleNote가 없어도 noteId가 있으면 fetch해서 받아와야함
    public var noteId: Int?
    
    public var range: NSRange
    public var bibleVerse: BibleVerse
    
    /// 노트가 수정되거나 삭제되면 여기에 저장됨. 노트 수정 완료 눌렀을때도 계속 노트화면에 존재 하도록 수정하고 싶다면 그때를 위해서 선언함
    public var updatedBibleNote: BibleNote?
    
    /// 노트를 처음 작성하는가?
    public var isFirstTimeToWriteNote: Bool = false
    
    // MARK: - Bind State
    public var hasNoteFetched: Bool = false
    
    public var noteModified: Bool = false
    
    public var deleted: Bool = false
    
    public var unexpectedErrorMessage: String = ""
    
    public init(bibleNote: BibleNote?, noteId: Int?, range: NSRange, bibleVerse: BibleVerse) {
      self.bibleNote = bibleNote
      self.noteId = noteId
      self.range = range
      self.bibleVerse = bibleVerse
    }
  }
  
  // MARK: - Properties
  public var initialState: State
  
  public let noteUseCase: BibleNoteUseCase
  
  public let textHasher: TextHashable
  
  public var initialNoteHash: String {
    if let text = currentState.bibleNote?.text {
      return textHasher.toHash(of: text)
    }
    return ""
  }
  
  public var bibleVerseContent: String {
    currentState.bibleVerse.content
  }
  
  public var bibleChapterVsVerse: String {
    "\(currentState.bibleVerse.chapter) : \(currentState.bibleVerse.verse)"
  }
  
  public var bibleName: String {
    currentState.bibleVerse.book.name
  }
  
  // MARK: - Lifecycle
  public init(initialState: State, noteUseCase: BibleNoteUseCase, textHasher: TextHashable) {
    self.textHasher = textHasher
    self.initialState = initialState
    self.noteUseCase = noteUseCase
  }
  
  deinit{
    print(Self.self, "deinit")
  }
  
  // MARK: - Reactor
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .refresh:
      if initialState.bibleNote == nil {
        /// 노트가 없고 noteId도 없는 경우 글 작성
        if initialState.noteId == nil {
          return Observable.concat([
            .just(.firstTimeToWriteNote(true)),
            .just(.hasNoteFetched(true)),
            .just(.hasNoteFetched(false))
          ])
        }
      }
      /// 노트가 없지만 id가 있는 경우! 또는 note도 있고 noteID도 있는
      /// BibleReading 화면에선 에선 노트아이디와 verseEntry를 줌. ( 존재하는 경우 ) BibleNote는 없지만 NoteId는 존재함.
      return Observable.concat([
        fetchNoteStream(),
        .just(.hasNoteFetched(true)),
        .just(.hasNoteFetched(false))
      ])
    case .noteContentModifiy(let modified):
      return updateNoteStream(with: modified)
    case .noteSave(let noteContent):
      return noteSaveStream(with: noteContent)
    case .noteDelete:
      return noteDeleteStream()
    }
  }
  
  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .none:
      break
    case .bibleNoteFetched(let note):
      newState.bibleNote = note
      newState.range = note.range
    case .firstTimeToWriteNote(let isFirstTime):
      newState.isFirstTimeToWriteNote = isFirstTime
    case .hasNoteFetched(let bool):
      newState.hasNoteFetched = bool
    case .noteModified(let newNote):
      newState.updatedBibleNote = newNote
    case .unexpectedError(let errorDescription):
      newState.unexpectedErrorMessage = errorDescription
    case .noteModifiedCompletion(let bool):
      newState.noteModified = bool
    case .noteDeleted:
      newState.updatedBibleNote = nil
      newState.deleted = true
    }
    return newState
  }
}
