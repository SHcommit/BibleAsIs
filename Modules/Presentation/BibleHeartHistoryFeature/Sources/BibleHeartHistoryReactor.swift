//
//  BibleHeartHistoryReactor.swift
//  MyActivityFeature
//
//  Created by 양승현 on 2/18/25.
//

import Common
import RxSwift
import ReactorKit
import Foundation
import DomainEntity
import DomainInterface
import DesignSystemItems
import DesignSystemInterface

public final class BibleHeartHistoryReactor: Reactor {
  public enum Action {
    case refreshHistory
    case deselectHeart(testament: BibleTestament, IndexPath: IndexPath)
    case removeAllHeart(for: IndexPath)
  }
  
  public enum Mutation {
    case heartItemsSet(sectionItems: [BibleTimelineHistoryVerseSectionItem], items: [[BibleTimelineHistoryVerseItem]])
    case heartDelete(IndexPath)
    case heartsDelete(IndexPath)
    case unexpectedErrorOccured(String)
    case sectionUpdated(IndexPath?)
    case shouldReloadSection(Bool)
    case shouldDeleteSection(Bool)
    
    case shouldRefresh(Bool)
  }
  
  public struct State {
    var heartSections: [BibleTimelineHistoryVerseSectionItem] = []
    var heartItems: [[BibleTimelineHistoryVerseItem]] = []
    
    var updatedSectionIndexPath: IndexPath?
    var shouldReloadSection: Bool = false
    var shouldDeleteSection: Bool = false
    
    var hasInitiallyFetched = false
    var shouldRefresh: Bool = false
    var unexpectedErrorMsg: String = ""
  }
  
  // MARK: - Properties
  public var initialState: State = .init()
  
  public var bibleHeartFetchUseCase: BibleHeartFetchUseCase
  
  public var bibleHeartDeleteUseCase: BibleHeartDeleteUseCase
  
  // MARK: - Lifecycle
  public init(
    bibleHeartFetchUseCase: BibleHeartFetchUseCase,
    bibleHeartDeleteUseCase: BibleHeartDeleteUseCase
  ) {
    self.bibleHeartFetchUseCase = bibleHeartFetchUseCase
    self.bibleHeartDeleteUseCase = bibleHeartDeleteUseCase
  }
  
  deinit {
    print(Self.self, "deint")
  }
  
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .refreshHistory:
      return fetchHeartHistoriesStream()
    case .deselectHeart(_, IndexPath: let IndexPath):
      return deleteHeartStream(indexPath: IndexPath)
    case .removeAllHeart(for: let indexPath):
      return removeAllHeartStream(for: indexPath)
    }
  }
  
  public func reduce(state: State, mutation: Mutation) -> State {
    var newValue = state
    switch mutation {
    case .heartItemsSet(let sectionItems, let items):
      newValue.heartSections = sectionItems
      newValue.heartItems = items
    case .heartDelete(let deletedIndexPath):
      newValue.updatedSectionIndexPath = deletedIndexPath
      if newValue.heartItems[deletedIndexPath.section].count == 1 {
        newValue.heartItems.remove(at: deletedIndexPath.section)
        newValue.heartSections.remove(at: deletedIndexPath.section)
      } else {
        var heartItems = newValue.heartItems[deletedIndexPath.section]
        
        heartItems.remove(at: deletedIndexPath.item)
        let heartItemsCount = heartItems.count
        
        // 이제 isFirst, isLast 다시 업데이트 해야함
        heartItems.indices.forEach { i in
          heartItems[i].isFirst = false
          heartItems[i].isLast = false
          
          if heartItemsCount == 1 {
            heartItems[i].isFirst = true
            heartItems[i].isLast = true
          } else if heartItemsCount == 2 {
            if i == 0 {
              heartItems[i].isFirst = true
            } else {
              heartItems[i].isLast = true
            }
          } else {
            if i == 0 {
              heartItems[i].isFirst = true
            } else if i == heartItemsCount - 1 {
              heartItems[i].isLast = true
            }
          }
          newValue.heartItems[deletedIndexPath.section] = heartItems
        }
      }
      newValue.heartItems.forEach { print($0.count) }
    case .heartsDelete(forSection: let forSection):
      newValue.heartSections.remove(at: forSection.section)
      newValue.heartItems.remove(at: forSection.section)
      newValue.updatedSectionIndexPath = forSection
    case .shouldRefresh(let refresh):
      newValue.shouldRefresh = refresh
      if refresh, !newValue.hasInitiallyFetched {
        newValue.hasInitiallyFetched = true
      }
    case .unexpectedErrorOccured(let errMsg):
      newValue.unexpectedErrorMsg = errMsg
    case .sectionUpdated(let sectionIndex):
      newValue.updatedSectionIndexPath = sectionIndex
    case .shouldReloadSection(let shouldReloadSpecificSection):
      newValue.shouldReloadSection = shouldReloadSpecificSection
      // 이렇게 초기화 꼭 안해도 되긴하는데.
      //      if !shouldReloadSpecificSection {
      //        newValue.updatedSectionIndexPath = nil
      //      }
    case .shouldDeleteSection(let shouldDeleteSpecificSection):
      newValue.shouldDeleteSection = shouldDeleteSpecificSection
      // 이렇게 초기화 꼭 안해도 되긴하는데.
      //      if !shouldDeleteSpecificSection {
      //        newValue.updatedSectionIndexPath = nil
      //      }
    }
    return newValue
  }
  
  // MARK: - Stream Helpers
  private func fetchHeartHistoriesAsObservable(
  ) -> Observable<(
    sections: [BibleTimelineHistoryVerseSectionItem],
    items: [[BibleTimelineHistoryVerseItem]]
  )> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      
      bibleHeartFetchUseCase.fetchAllLikedVerses(completion: { result in
        switch result {
        case .success((let hearts, let verses)):
          let items = BibleHeartMapper.toSearchedVerseItems(fromHearts: hearts, verses: verses)
          observer.onNext((items.sections, items.items))
          observer.onCompleted()
        case .failure(let failure):
          observer.onError(failure)
        }
      })
      return Disposables.create()
    }
  }
  
  private func fetchHeartHistoriesStream() -> Observable<Mutation> {
    return Observable.concat([
      fetchHeartHistoriesAsObservable().map { .heartItemsSet(sectionItems: $0.sections, items: $0.items) },
      .just(.shouldRefresh(true)),
      .just(.shouldRefresh(false))
    ])
  }
  
  private func deleteHeartAsObservable(indexPath: IndexPath) -> Observable<Void> {
    let heart = currentState.heartItems[indexPath.section][indexPath.item]
    guard let heartId = heart.heartId else {
      return .error(NSError(
        domain: "Presentation",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "하트 정보가 없습니다."])) }
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      bibleHeartDeleteUseCase.deleteHeart(byHeartId: heartId) { result in
        switch result {
        case .success:
          observer.onNext(())
          observer.onCompleted()
        case .failure(let failure):
          observer.onError(failure)
        }
      }
      return Disposables.create()
    }
  }
  
  private func deleteHeartStream(indexPath: IndexPath) -> Observable<Mutation> {
    return deleteHeartAsObservable(
      indexPath: indexPath
    ).flatMap { [weak self] _ -> Observable<Mutation> in
      guard let self else { return .error(CommonError.referenceDeallocated) }
      
      /// 이러면 섹션 제거
      if currentState.heartItems[indexPath.section].count == 1 {
        return Observable.concat([
          .just(.heartDelete(indexPath)),
          .just(.shouldDeleteSection(true)),
          .just(.shouldDeleteSection(false))
        ])
      } else {
        return Observable.concat([
          /// 아닐 경우 아이템 제거 후 섹션 리로드
          .just(.heartDelete(indexPath)),
          .just(.shouldReloadSection(true)),
          .just(.shouldReloadSection(false))
        ])
      }
    }
  }
  
  private func removeAllHeartAsObservable(for indexPath: IndexPath) -> Observable<Void> {
    let section = indexPath.section
    let hearts = currentState.heartItems[section]
    var heartIDList: [Int] = []
    for heart in hearts {
      guard let heartId = heart.heartId else {
        return .error(NSError(
          domain: "Presentation",
          code: 1,
          userInfo: [NSLocalizedDescriptionKey: "하트 정보가 없습니다."])) }
      heartIDList.append(heartId)
    }
    
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create()
      }
      
      bibleHeartDeleteUseCase.deleteHearts(byHeartIdList: heartIDList.map { $0 }) { result in
        switch result {
        case .success:
          observer.onNext(())
          observer.onCompleted()
        case .failure(let failure):
          observer.onError(failure)
        }
      }
      return Disposables.create()
    }
  }
  
  /// observer.onNext(Mutation.heartsDelete(indexPath))
  private func removeAllHeartStream(for indexPath: IndexPath) -> Observable<Mutation> {
    return removeAllHeartAsObservable(for: indexPath)
      .flatMap { _ in
        return Observable.concat([
          .just(.heartsDelete(indexPath)),
          .just(.shouldDeleteSection(true)),
          .just(.shouldDeleteSection(false))
        ])
      }
  }
}
