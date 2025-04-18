//
//  BibleSearchReactor.swift
//  BibleSearchFeature
//
//  Created by 양승현 on 2/21/25.
//

import Common
import RxSwift
import Foundation
import ReactorKit
import DomainEntity
import DomainInterface
import DesignSystemItems
import DesignSystemInterface

public final class BibleSearchReactor: Reactor {
  public typealias SearchedTimelineHistories = (
    sections: [BibleTimelineHistoryVerseSectionItem],
    items: [[BibleTimelineHistoryVerseItem]])
  public typealias ItemIndex = Int
  public typealias SectionIndex = Int
  public typealias WannaRefresh = Bool
  
  // MARK: - Constants
  public enum Action {
    
    case refresh
    case tagDelete(ItemIndex)
    case specificHistoriesDelete(SectionIndex)
  }
  
  public enum Mutation {
    
    case recentlySearchedQueriesSet(BibleRecentlySearchedQueries)
    case timelineHistoriesSet(SearchedTimelineHistories)
    case timelineHistoryRefresh(WannaRefresh)
    case recentlySearchedQueriesRefresh(WannaRefresh)
    
    case recentlySearchedQueryDelete(BibleRecentlySearchedQuery)
    case recentlySearchedQueryDeleteIndex(ItemIndex?)
    
    case searchedSpecificHistoriesDelete(SectionIndex)
    case deletedSpecificHistoriesUpdate(SectionIndex?)
    
    case none
    case error(String)
  }
  
  public struct State {
    var tempState: Bool = false
    
    /// 이거에 바인딩 걸어두면 자잘한거도 전체적으로 리로드 될수있기에 아래처럼 불 변수로.. (특정한 로직 삭제해도 배열은 변화하기에) ㅇㅅㅇ
    var recentlySearchedQueries: BibleRecentlySearchedQueries = .init(queries: [])
    var timelineHistoryItems: [[BibleTimelineHistoryVerseItem]] = []
    var timelineHistorySections: [BibleTimelineHistoryVerseSectionItem] = []
    
    var deletedTimelineHistory: SectionIndex?
    
    var recentlySearchedQueryRefresh = false
    var deletedRecentlyQueryIndex: Int?
    var timelineHistoryRefresh = false
    
    var unexpectedErrorOccured: String = ""
    
    var hasInitiallyFetched = false
  }
  
  // MARK: - Properties
  public var initialState: State = .init()
  
  private let recentlySearchedRepository: BibleRecentlySearchedQueryRepository
  
  private let searchHistoryUseCase: BibleSearchHistoryUseCase
  
  private var forTest = false
  
  // MARK: - Lifecycle
  public init(
    recentlySearchedRepository: BibleRecentlySearchedQueryRepository,
    searchHistoryUseCase: BibleSearchHistoryUseCase
  ) {
    self.recentlySearchedRepository = recentlySearchedRepository
    self.searchHistoryUseCase = searchHistoryUseCase
  }
  
  // MARK: - Helpers
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .refresh:
      return Observable.concat([
        // 테스트용 !
//        .just(.none),
        fetchSearchHistoriesStream(),
        fetchRecentlySearchedQueries(),
        .just(Mutation.timelineHistoryRefresh(true)),
        .just(Mutation.recentlySearchedQueriesRefresh(true)),
        .just(Mutation.timelineHistoryRefresh(false)),
        .just(Mutation.recentlySearchedQueriesRefresh(false))
      ])
    case .tagDelete(let index):

      guard (0..<currentState.recentlySearchedQueries.queries.count).contains(index) else {
        return .just(Mutation.error("에러가 발생해 \(index) 태그를 삭제할 수 없습니다."))
      }
      let deletionQuery = currentState.recentlySearchedQueries.queries[index]
      recentlySearchedRepository.deleteRecentlySearchedQuery(deletionQuery)
      return Observable.concat([
        .just(Mutation.recentlySearchedQueryDelete(deletionQuery)),
        .just(Mutation.recentlySearchedQueryDeleteIndex(index)),
        .just(Mutation.recentlySearchedQueryDeleteIndex(nil))
      ])
    case .specificHistoriesDelete(let sectionIndex):
      return Observable.concat([
        deleteSpecificSearchedHistoriesStream(for: sectionIndex),
        .just(Mutation.deletedSpecificHistoriesUpdate(sectionIndex)),
        .just(Mutation.deletedSpecificHistoriesUpdate(nil))
      ])
    }
  }
  
  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .none:
      /// 이거는 테스트용도인데,
      /// .just(.none)으로 방출안하면 실행안됨 ㅇㅅㅇ
      newState.recentlySearchedQueries = .init(queries: [
        .init(date: .init(), query: "창세기 1:1"),
        .init(date: .init(), query: "출애굽기 1:1"),
        .init(date: .init(), query: "레위기 1:1"),
        .init(date: .init(), query: "고린도전서 1:1"),
        .init(date: .init(), query: "고린도후서 1:2"),
        .init(date: .init(), query: "고린도전서 1:3")])
      
      newState.timelineHistorySections = Self.makeStubSections()
      newState.timelineHistoryItems = Self.makeStubItems()
    case .recentlySearchedQueriesSet(let searchedQueries):
      newState.recentlySearchedQueries = searchedQueries
    case .timelineHistoriesSet((let sections, let items)):
      newState.timelineHistoryItems = items
      newState.timelineHistorySections = sections
      if !newState.hasInitiallyFetched {
        newState.hasInitiallyFetched = true
      }
    case .timelineHistoryRefresh(let bool):
      newState.timelineHistoryRefresh = bool
    case .recentlySearchedQueriesRefresh(let bool):
      newState.recentlySearchedQueryRefresh = bool
    case .recentlySearchedQueryDelete(let deletionQuery):
      newState.recentlySearchedQueries.remove(query: deletionQuery)
    case .error(let errorMsg):
      newState.unexpectedErrorOccured = errorMsg
      if !newState.hasInitiallyFetched {
        newState.hasInitiallyFetched = true
      }
    case .recentlySearchedQueryDeleteIndex(let index):
      newState.deletedRecentlyQueryIndex = index
    case .searchedSpecificHistoriesDelete(let deletedSectionIndex):
      newState.timelineHistorySections.remove(at: deletedSectionIndex)
      newState.timelineHistoryItems.remove(at: deletedSectionIndex)
      
    case .deletedSpecificHistoriesUpdate(let sectionIndex):
      newState.deletedTimelineHistory = sectionIndex
    }
    return newState
  }
  
  // MARK: - private Stream Helpers
  private func fetchSearchHistoriesStream() -> Observable<Mutation> {
    return Observable.create { [weak self] observer in
      guard let self else {
        observer.onNext(.error(CommonError.referenceDeallocated.localizedDescription))
        observer.onNext(.error(""))
        observer.onCompleted()
        return Disposables.create()
      }
      searchHistoryUseCase.fetchAllGroupedSearchHistory { result in
        switch result {
        case .success(let bibleSearchHistories):
          let (sections, items) = BibleHeartMapper.toSearchedVerseItems(from: bibleSearchHistories)
          observer.onNext(Mutation.timelineHistoriesSet((sections, items)))
          observer.onCompleted()
        case .failure(let failure):
          observer.onError(failure)
        }
      }
      
      return Disposables.create()
    }
  }
  
  private func fetchRecentlySearchedQueries() -> Observable<Mutation> {
    return Observable.create { [weak self] observer in
      guard let self else {
        observer.onNext(.error(CommonError.referenceDeallocated.localizedDescription))
        observer.onNext(.error(""))
        observer.onCompleted()
        return Disposables.create()
      }
      
      let fetched = recentlySearchedRepository.fetchAllRecentlySearchedQueries() ?? .init(queries: [])
      observer.onNext(.recentlySearchedQueriesSet(fetched))
      observer.onCompleted()
      
      return Disposables.create()
    }
  }
  
  private func deleteSpecificSearchedHistoriesStream(for sectionIndex: Int) -> Observable<Mutation> {
    return Observable.create { [weak self] observer in
      guard let self else {
        observer.onNext(.error(CommonError.referenceDeallocated.localizedDescription))
        observer.onNext(.error(""))
        observer.onCompleted()
        return Disposables.create()
      }
      
      let sectionItem = currentState.timelineHistorySections[sectionIndex]
      // 디비에 날짜가 저장될 형식은 2025-02-01 이런 형식 맞음!
      guard let (month, day) = sectionItem.toMonthDayTuple else {
        observer.onNext(.error("오류가 발생되어 데이터를 삭제할 수 없습니다."))
        observer.onNext(.error(""))
        observer.onCompleted()
        return Disposables.create()
      }
      searchHistoryUseCase.deleteBibleSearchHistories(
        forYear: sectionItem.year,
        month: month,
        day: day) { result in
          switch result {
          case .success:
            observer.onNext(Mutation.searchedSpecificHistoriesDelete(sectionIndex))
            observer.onCompleted()
          case .failure(let failure):
            observer.onNext(.error(failure.localizedDescription))
            observer.onNext(.error(""))
            observer.onCompleted()
          }
        }
      return Disposables.create()
    }
  }
}

// MARK: - BibleRecentSearchKeywordsAdapterDataSource
extension BibleSearchReactor: BibleRecentSearchKeywordsAdapterDataSource {

  public var numberOfItems: Int {
    currentState.recentlySearchedQueries.queries.count
  }
  
  public func item(indexPath: IndexPath) -> String {
    currentState.recentlySearchedQueries.queries[indexPath.item].query

  }
}

fileprivate extension BibleSearchReactor {
  static func makeStubSections() -> [BibleTimelineHistoryVerseSectionItem] {
    [
      BibleTimelineHistoryVerseSectionItem(monthDay: "1월 25일", year: "2025"),
      BibleTimelineHistoryVerseSectionItem(monthDay: "1월 24일", year: "2025"),
      BibleTimelineHistoryVerseSectionItem(monthDay: "1월 23일", year: "2025"),
      BibleTimelineHistoryVerseSectionItem(monthDay: "1월 22일", year: "2025")
    ]
  }
  
  static func makeStubItems() -> [[BibleTimelineHistoryVerseItem]] {
    let verse = "하나님이 이르시되 물들은 생물은 번성하여 움직이는 모든 생물을 그 종류대로, 날개있는 모든 새를 그 종류대로 창조하시니 하나님이 보시기에 좋았더라"
    let verse2 = "하나님이 이르시되 물들은 생물은 번성하여 움직이는 모든 생물을 그 종류대로, 날개있는 모든 새를 그 종류대로 창조하시니 하나님이 보시기에 좋았더라 하나님이 이르시되 물들은 생물은 번성하여 움직이는 모든 생물을 그 종류대로, 날개있는 모든 새를 그 종류대로 창조하시니 하나님이 보시기에 좋았더라"
    let verse3 = "하나님이 이르시되 물들은 생물은 번성하여 움직이는 모든 생물을 그 종류대로"
    
    let items: [[BibleTimelineHistoryVerseItem]] = [
      [
        BibleTimelineHistoryVerseItem(
          reference: .init(book: .acts, chapter: 12, verse: 3), verseContent: verse,
          heartReference: nil,
          isFirst: true, isLast: false),
        BibleTimelineHistoryVerseItem(
          reference: .init(book: .colossians, chapter: 12, verse: 3), verseContent: verse2,
          heartReference: nil,
          isFirst: false, isLast: false),
        BibleTimelineHistoryVerseItem(
          reference: .init(book: .genesis, chapter: 12, verse: 3), verseContent: verse3,
          heartReference: nil,
          isFirst: false, isLast: false),
        BibleTimelineHistoryVerseItem(
          reference: .init(book: .genesis, chapter: 12, verse: 3), verseContent: verse2,
          heartReference: nil,
          isFirst: false, isLast: true)
      ], [
        BibleTimelineHistoryVerseItem(
          reference: .init(book: .matthew, chapter: 12, verse: 3), verseContent: verse3,
          heartReference: nil,
          isFirst: true, isLast: false),
        BibleTimelineHistoryVerseItem(
          reference: .init(book: .genesis, chapter: 12, verse: 3), verseContent: verse,
          heartReference: nil,
          isFirst: false, isLast: true)
      ], [
        BibleTimelineHistoryVerseItem(
          reference: .init(book: .genesis, chapter: 12, verse: 3), verseContent: verse2,
          heartReference: nil,
          isFirst: true, isLast: true)
      ], [
        BibleTimelineHistoryVerseItem(
          reference: .init(book: .genesis, chapter: 12, verse: 3), verseContent: verse3,
          heartReference: nil,
          isFirst: true, isLast: false),
        BibleTimelineHistoryVerseItem(
          reference: .init(book: .james, chapter: 12, verse: 3), verseContent: verse2,
          heartReference: nil,
          isFirst: false, isLast: false),
        BibleTimelineHistoryVerseItem(
          reference: .init(book: .james, chapter: 12, verse: 3), verseContent: verse,
          heartReference: nil,
          isFirst: false, isLast: false),
        BibleTimelineHistoryVerseItem(
          reference: .init(book: .james, chapter: 12, verse: 3), verseContent: verse,
          heartReference: nil,
          isFirst: false, isLast: true)
      ]
    ]
    return items
  }
}
