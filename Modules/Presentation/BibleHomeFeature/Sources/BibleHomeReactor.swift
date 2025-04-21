//
//  BibleHomeReactor.swift
//  BibleHomeFeature
//
//  Created by 양승현 on 2/10/25.
//

import Common
import RxSwift
import Foundation
import ReactorKit
import DomainEntity
import CoreInterface
import DomainInterface
import DesignSystemItems

public final class BibleHomeReactor: Reactor {
  public enum Action {
    case oldTestamentBooksShow
    case newTestamentBooksShow
    
    case oldTestamentsCategoryTap(IndexPath)
    case newTestamentsCategoryTap(IndexPath)
    case viewWillAppearForBookclip
  }
  
  public enum Mutation {
    case none
    /// 책 확장
    case expandedOldTestamentBooksSet(Bool)
    case expandedNewTestamentBooksSet(Bool)
    case oldTestamentCategoryToggleToShow(IndexPath?)
    case newTestamentCategoryToggleToShow(IndexPath?)
    
    case updatedBookclipSet(RecentBibleClip?)
    case shouldReloadForClip(Bool)
  }
  
  public struct State {
    var updatableIndexPath: IndexPath?
    var oldTestamentExpanded: Bool = false
    var newTestamentExpanded: Bool = false
    var oldTestamentItems: [BibleHomeItem] = []
    var newTestamentItems: [BibleHomeItem] = []
    
    /// 여기서 관리해도 될 듯한데
    /// item에서 관리하네?
    var currentClip: RecentBibleClip
    var updatedClip: RecentBibleClip?
    
    /// 여기서는 new, oldTestamentItems 데이터가 존재하는지 여부에 따라 판단
    var hasInitiallyFetched = false
    
    // MARK: - Bind
    var shouldReloadForClip: Bool = false
  }
  
  private(set) var recentBibleBookclipRepository: RecentBibleBookclipRepository
  
  // MARK: - Properties
  public var initialState: State
  
  // MARK: - Lifecycle
  public init(recentBibleBookclipRepository: RecentBibleBookclipRepository) {
    self.recentBibleBookclipRepository = recentBibleBookclipRepository
    let currentClip = recentBibleBookclipRepository.fetchRecentClip()
    initialState = .init(currentClip: currentClip)
    
    initialState.oldTestamentItems = BibleItemFactory.makeBibleHomeItem(
      testamentType: .old, clipInfo: currentClip)
    initialState.newTestamentItems = BibleItemFactory.makeBibleHomeItem(
      testamentType: .new, clipInfo: currentClip)
    initialState.hasInitiallyFetched = true
  }
  
  // MARK: - Reactor
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .oldTestamentBooksShow:
      let expanded = currentState.oldTestamentExpanded
      return Observable.just(Mutation.expandedOldTestamentBooksSet(!expanded))
    case .newTestamentBooksShow:
      let expanded = currentState.newTestamentExpanded
      return Observable.just(Mutation.expandedNewTestamentBooksSet(!expanded))
    case .oldTestamentsCategoryTap(let indexPath):
      return Observable.concat([
        Observable.just(Mutation.oldTestamentCategoryToggleToShow(indexPath)),
        Observable.just(Mutation.oldTestamentCategoryToggleToShow(nil))
      ])
    case .newTestamentsCategoryTap(let indexPath):
      return Observable.concat([
        Observable.just(Mutation.newTestamentCategoryToggleToShow(indexPath)),
        Observable.just(Mutation.newTestamentCategoryToggleToShow(nil))
      ])
    case .viewWillAppearForBookclip:
      let newClip = recentBibleBookclipRepository.fetchRecentClip()
      if currentState.currentClip == newClip { return .just(.none) }
      if currentState.currentClip.book == newClip.book && currentState.currentClip.chapter == newClip.chapter {
        return .just(.none)
      }
      
      // todo 리로드하기
      return Observable.concat([
        .just(.updatedBookclipSet(newClip)),
        .just(.shouldReloadForClip(true)),
        .just(.updatedBookclipSet(nil)),
        .just(.shouldReloadForClip(false))
      ])
      
    }
  }
  
  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .none: break
    case .expandedOldTestamentBooksSet(let expanded):
      newState.oldTestamentExpanded = expanded
    case .expandedNewTestamentBooksSet(let expanded):
      newState.newTestamentExpanded = expanded
    case .oldTestamentCategoryToggleToShow(let indexPath):
      if let indexPath {
        newState.oldTestamentItems[indexPath.item].isExpended.toggle()
      }
      newState.updatableIndexPath = indexPath
    case .newTestamentCategoryToggleToShow(let indexPath):
      if let indexPath {
        newState.newTestamentItems[indexPath.item].isExpended.toggle()
      }
      newState.updatableIndexPath = indexPath
    case .updatedBookclipSet(let updatedBookclip):
      if let updatedBookclip {
        newState.updatedClip = updatedBookclip
        let currentClip = newState.currentClip
        if newState.currentClip.testament == .old {
          guard let index = newState.oldTestamentItems.firstIndex(
            where: { $0.bookTitle == currentClip.book }) else { assertionFailure("1. 반드시 인덱스 찾아야합니다."); break }
          newState.oldTestamentItems[index].isClipped = false
          newState.oldTestamentItems[index].chapterItems[currentClip.chapter-1].isClipped = false
        } else {
          guard let index = newState.newTestamentItems.firstIndex(
            where: { $0.bookTitle == currentClip.book }) else { assertionFailure("1. 반드시 인덱스 찾아야합니다."); break }
          newState.newTestamentItems[index].isClipped = false
          newState.newTestamentItems[index].chapterItems[currentClip.chapter-1].isClipped = false
        }
        
        if updatedBookclip.testament == .old {
          guard let index = newState.oldTestamentItems.firstIndex(
            where: { $0.bookTitle == updatedBookclip.book }) else { assertionFailure("1. 반드시 인덱스 찾아야합니다."); break }
          newState.oldTestamentItems[index].isClipped = true
          newState.oldTestamentItems[index].chapterItems[updatedBookclip.chapter-1].isClipped = true
        } else {
          guard let index = newState.newTestamentItems.firstIndex(
            where: { $0.bookTitle == updatedBookclip.book }) else { assertionFailure("1. 반드시 인덱스 찾아야합니다."); break }
          newState.newTestamentItems[index].isClipped = true
          newState.newTestamentItems[index].chapterItems[updatedBookclip.chapter-1].isClipped = true
        }
        
        print("클립 상태 업데이트 완료.")
      } else {
        guard let updatedClip = newState.updatedClip else { break }
        newState.currentClip = updatedClip
        newState.updatedClip = nil
      }
    case .shouldReloadForClip(let shouldReload):
      newState.shouldReloadForClip = shouldReload
    }
    return newState
  }
}
