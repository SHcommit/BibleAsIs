//
//  BibleNoteHomeReactor.swift
//  BibleNoteHomeFeature
//
//  Created by 양승현 on 3/7/25.
//

import Common
import RxSwift
import ReactorKit
import Foundation
import DomainEntity
import DomainInterface
import DesignSystemInterface

/// BibleNotes, items가 동시에 관리되어야함
///
/// 필수!
public final class BibleNoteHomeReactor: Reactor {
  public enum Action {
    case refresh
    case nextPage
     
    /// 2. 사용자가 수정해서 로직 상으로 list 위로 올려보내야 해서 젝
    case noteUpdated(note: BibleNote, row: Int)
    case noteDeleted(row: Int)
  }
  
  public enum Mutation {
    case none
    case unexpectedErrorOccured(String)
    
    // MARK: - Pagination
    case notesFetch(items: [BibleVerse], notes: [BibleNote], totalNotes: Int, wasNextPage: Bool)
    case loadingNextPageSet(Bool)
    case reloadForNextPage(Bool)
    
    /// 1. 사용자가 삭제
    /// 2. 사용자가 수정해서 로직 상으로 list 위로 올려보내야 해서 젝
    case noteDeleted(row: Int)
    case userDeleteHandleCompletion(Bool)
    case noteUpdated(row: Int, note: BibleNote)
    case noteUpdatedCompletion(Bool)
  }
  
  public struct State {
    // MARK: 아이템 제거시 items, notes 동기화 해주어야함
    var items: [BibleVerse] = []
    var notes: [BibleNote] = []
    var page = 1
    var numberOfPrevItems: Int = 0
    var isLoading = false
    var reloadForNewPage = false
    var noteDeleted = false
    var noteUpdated = false
    var deletedNoteIndex: Int?
    var updatedNoteIndex: Int?
    
    var hasInitiallyFetched = false
    
    var totalNotes = 0
  }
  
  // MARK: - Properties
  
  private let pageSize = 15  
  
  public var initialState: State = .init()
  
  public let bibleNoteUseCase: BibleNoteUseCase
  
  public let bibleVerseFetchUseCase: BibleVerseFetchUseCase
  
  // MARK: - Lifecycle
  public init(
    bibleNoteUseCase: BibleNoteUseCase,
    bibleVerseFetchUseCase: BibleVerseFetchUseCase
  ) {
    self.bibleNoteUseCase = bibleNoteUseCase
    self.bibleVerseFetchUseCase = bibleVerseFetchUseCase
  }
  
  // MARK: - Reactor
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .refresh:
      return Observable.concat([
        fetchNotesStream(page: 1, forRefreshing: true),
        .just(Mutation.reloadForNextPage(true)),
        .just(Mutation.reloadForNextPage(false))
      ])
    case .nextPage:
      return Observable.concat([
        .just(Mutation.loadingNextPageSet(true)),
        fetchNotesStream(page: currentState.page, forRefreshing: false)
          .delay(.milliseconds(372), scheduler: MainScheduler.instance),
        .just(Mutation.loadingNextPageSet(false))
      ])
    case .noteUpdated(let note, let row):
      return Observable.concat([
        .just(.noteUpdated(row: row, note: note)),
        .just(.noteUpdatedCompletion(true)),
        .just(.noteUpdatedCompletion(false))
      ])
    case .noteDeleted(let row):
      return Observable.concat([
        .just(.noteDeleted(row: row)),
        .just(.userDeleteHandleCompletion(true)),
        .just(.userDeleteHandleCompletion(false))])
    }
  }
  
  // MARK: 아이템 제거시 items, notes 동기화 해주어야함
  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .none:
      break
    case .notesFetch(let items, let notes, let totalNotes, let wasRefreshed):
      newState.numberOfPrevItems = newState.items.count
      if wasRefreshed {
        newState.items = items
        newState.notes = notes
        newState.page = 2
      } else {
        newState.items.append(contentsOf: items)
        newState.notes.append(contentsOf: notes)
        newState.page += 1
      }
      newState.totalNotes = totalNotes
    case .loadingNextPageSet(let isLoading):
      newState.isLoading = isLoading
    case .reloadForNextPage(let wannaRefresh):
      newState.reloadForNewPage = wannaRefresh
      if !hasInitiallyFetched, wannaRefresh {
        newState.hasInitiallyFetched = true
      }
    case .unexpectedErrorOccured(let unexpectedError):
      print(unexpectedError)
 
      if !hasInitiallyFetched, !unexpectedError.isEmpty, unexpectedError.count > 0 {
        newState.hasInitiallyFetched = true
      }
    case .noteDeleted(row: let row):
      newState.notes.remove(at: row)
      newState.items.remove(at: row)
      newState.deletedNoteIndex = row
    case .userDeleteHandleCompletion(let bool):
      newState.noteDeleted = bool
      if !bool {
        newState.deletedNoteIndex = nil
      }
    case .noteUpdated(row: let row, note: let newNote):
      newState.notes[row] = newNote
      let removedNote = newState.notes.remove(at: row)
      let removedItem = newState.items.remove(at: row)
      newState.notes.insert(removedNote, at: 0)
      newState.items.insert(removedItem, at: 0)
      newState.updatedNoteIndex = row
    case .noteUpdatedCompletion(let bool):
      newState.noteUpdated = bool
      if !newState.noteUpdated {
        newState.updatedNoteIndex = nil
      }
    }
    return newState
  }
}

// MARK: - Private Helpers
private extension BibleNoteHomeReactor {
  /// 페이지 첫장은 1
  func fetchNotesStream(page: Int, forRefreshing: Bool) -> Observable<Mutation> {
    return fetchNotesAsObservable(page: page, pageSize: pageSize)
      .flatMap { [weak self] (notes: [BibleNote], totalNotes: Int) in
        guard let self else {
          return Observable.just(
            Mutation.unexpectedErrorOccured(CommonError.referenceDeallocated.localizedDescription))
        }
        
        let bibleRefs = notes.compactMap { note -> BibleReference? in
          guard let bibleRef = BibleReference(bibleReferenceId: note.verseId) else {
            assertionFailure("이거 절대 오류가 날 수 없는거임 해당 id 확인바람: \(note.verseId)"); return nil
          }
          return bibleRef
        }
        
        return fetchBibleVersesAsObservable(forReferences: bibleRefs)
          .map { verses in
            return Mutation.notesFetch(
              items: verses,
              notes: notes,
              totalNotes: totalNotes,
              wasNextPage: forRefreshing)
          }
      }
  }
  
  // MARK: - AsSingle
  func fetchNotesAsObservable(page: Int, pageSize: Int) -> Observable<(notes: [BibleNote], totalNotes: Int)> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      bibleNoteUseCase.fetchNotes(page: page, pageSize: pageSize) { result in
        switch result {
        case .success(let entry):
          observer.onNext(entry)
          observer.onCompleted()
        case .failure(let error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
  
  func fetchBibleVersesAsObservable(forReferences refs: [BibleReference]) -> Observable<[BibleVerse]> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      bibleVerseFetchUseCase.fetchBibleVerses(forReferences: refs) { result in
        switch result {
        case .success(let entry):
          observer.onNext(entry)
          observer.onCompleted()
        case .failure(let error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
}

// MARK: - BibleNoteTableViewAdapterDataSource
extension BibleNoteHomeReactor: BibleNoteTableViewAdapterDataSource {
  public var hasInitiallyFetched: Bool {
    currentState.hasInitiallyFetched
  }
  
  public var numberOfItems: Int {
    currentState.items.count
  }
  
  public func item(for indexPath: IndexPath) -> BibleVerse {
    currentState.items[indexPath.row]
  }
  
  public var hasNextPage: Bool {
    let capacity = (currentState.page) * pageSize - currentState.totalNotes
    if capacity <= 0 {
      return true
    } else if capacity != 0, capacity / pageSize < 1 {
      return true
    }
    return false
  }
  
  public var isLoading: Bool {
    currentState.isLoading
  }
}
