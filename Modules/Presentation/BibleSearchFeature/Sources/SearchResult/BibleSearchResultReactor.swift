//
//  BibleSearchResultReactor.swift
//  BibleSearchFeature
//
//  Created by 양승현 on 2/25/25.
//

import Common
import RxSwift
import ReactorKit
import Foundation
import DomainEntity
import DomainInterface
import DesignSystemItems
import DesignSystemInterface

public final class BibleSearchResultReactor: Reactor {
  public enum Action {
    case queryFetch(String)
    case nextPage
    case SearchedUserQuerySaveInDiskMemory(indexPath: IndexPath)
  }
  
  public enum Mutation {
    case none
    case searchQueryFetch(query: String, items: [BibleVerseItem], totalVerses: Int, wasNextPage: Bool)
    case loadingNextPageSet(Bool)
    case reloadForNextPage(Bool)
    case unexpectedErrorOccured(String?)
    case isSearchResultEmpty(Bool)
  }
  
  public struct State {
    var items: [BibleVerseItem] = []
    var page = 1
    var isLoading = false
    var reloadForNewPage = false
    var isSearchResultEmpty = false
    var lastQuery: String?
    var totalVerses: Int = 0
    var numberOfPrevItems: Int = 0
    var unexpectedErrorMSg: String?
  }
  
  // MARK: - Properties
  private let pageSize = 15
  
  public var initialState: State = .init()
  
  private let searchQueryFetchRepository: BibleSearchQueryFetchRepository
  
  private let bibleSearchHistoryUseCase: BibleSearchHistoryUseCase
  
  private let bibleRecentlySearchedQueryRepository: BibleRecentlySearchedQueryRepository
  
  // MARK: - Lifecycle
  init(
    searchQueryFetchRepository: BibleSearchQueryFetchRepository,
    bibleSearchHistoryUseCase: BibleSearchHistoryUseCase,
    bibleRecentlySearchedQueryRepository: BibleRecentlySearchedQueryRepository
  ) {
    self.searchQueryFetchRepository = searchQueryFetchRepository
    self.bibleSearchHistoryUseCase = bibleSearchHistoryUseCase
    self.bibleRecentlySearchedQueryRepository = bibleRecentlySearchedQueryRepository
  }
  
  // MARK: - Reactor
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .queryFetch(let query):
      if query == currentState.lastQuery {
        return .empty()
      }
      return fetchSearchQueryStream(query, page: 1, forNextPage: false)
    case .nextPage:
      guard let lastQuery = currentState.lastQuery else {
        return Observable.concat([
          .just(.loadingNextPageSet(true)),
          .just(.unexpectedErrorOccured("이전 검색어를 찾을 수 없습니다")),
          .just(.loadingNextPageSet(false))
        ])
      }
      return fetchSearchQueryStream(lastQuery, page: currentState.page, forNextPage: true)
    case .SearchedUserQuerySaveInDiskMemory(indexPath: let indexPath):
      let item = currentState.items[indexPath.row]
      return saveSearchQueryHistoryInformation(about: item)
    }
  }
  
  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .searchQueryFetch(let query, let items, let totalVerses, let wasNextPage):
      newState.numberOfPrevItems = newState.items.count
      if wasNextPage {
        newState.items.append(contentsOf: items)
        newState.page += 1
      } else {
        newState.items = items
        newState.lastQuery = query
        newState.page = 2
      }
      newState.totalVerses = totalVerses
    case .loadingNextPageSet(let isLoading):
      newState.isLoading = isLoading
    case .reloadForNextPage(let wannaRefresh):
//      newState.isLoading = false
      newState.reloadForNewPage = wannaRefresh
    case .none: break
    case .unexpectedErrorOccured(let errMsg):
      newState.unexpectedErrorMSg = errMsg
    case .isSearchResultEmpty(let isEmpty):
      newState.isSearchResultEmpty = isEmpty
      if isEmpty {
        newState.page = 1
        newState.isLoading = false
      }
    }
    return newState
  }
  
  // MARK: - Private Helpers
  private func fetchSearchQueryAsObservable(_ query: String, page: Int, forNextPage: Bool) -> Observable<(verses: [BibleVerse], totalVerses: Int)> {
    return Observable.create { [weak self] observer in
      guard let self else {
        observer.onError(CommonError.referenceDeallocated)
        return Disposables.create()
      }
      
      searchQueryFetchRepository.fetchQuery(query, page: page, pageSize: pageSize) { result in
        switch result {
        case .success(let success):
          observer.onNext(success)
          observer.onCompleted()
        case .failure(let failure):
          observer.onError(failure)
        }
      }
      return Disposables.create()
    }
  }
  
  private func fetchSearchQueryStream(_ query: String, page: Int, forNextPage: Bool) -> Observable<Mutation> {
    return fetchSearchQueryAsObservable(query, page: page, forNextPage: forNextPage)
      .flatMap { entry -> Observable<Mutation> in
        let verses = entry.verses
        let totalVerses = entry.totalVerses
        if verses.isEmpty {
          return Observable.concat([
            .just(.searchQueryFetch(query: query, items: [], totalVerses: 0, wasNextPage: false)),
            .just(.isSearchResultEmpty(true)),
            .just(.isSearchResultEmpty(false))
          ])
        }
        
        let toItems = verses.map {
          BibleVerseItem(
            reference: .init(book: $0.book, chapter: $0.chapter, verse: $0.verse),
            verseContent: $0.content, isOnHeart: false, highlights: [])
        }
        
        /// 첫 검색 결과
        if !forNextPage {
          return Observable.concat([
            .just(.searchQueryFetch(query: query, items: toItems, totalVerses: totalVerses, wasNextPage: forNextPage)),
            .just(Mutation.reloadForNextPage(true)),
            .just(Mutation.reloadForNextPage(false))
          ])
        }
        
        /// 다음 페이지
        return Observable.concat([
          .just(Mutation.loadingNextPageSet(true)),
          .just(.searchQueryFetch(
            query: query, items: toItems, totalVerses: totalVerses, wasNextPage: forNextPage)
          ).delay(.milliseconds(382), scheduler: MainScheduler.instance),
          .just(Mutation.loadingNextPageSet(false))
        ])
      }
  }
  
  private func saveSearchQueryHistoryInformation(about item: BibleVerseItem) -> Observable<Mutation> {
    return Observable.create { [weak self] observer in
      guard let self else {
        observer.onError(CommonError.referenceDeallocated)
        return Disposables.create()
      }
      
      if let query = currentState.lastQuery {
        if let searchedQueries = bibleRecentlySearchedQueryRepository.fetchAllRecentlySearchedQueries() {
          /// 중복 방지.
          if !searchedQueries.queries.contains(where: { $0.query == query}) {
            bibleRecentlySearchedQueryRepository.addRecentlySearchedQuery(.init(date: Date(), query: query))
          }
        } else {
          bibleRecentlySearchedQueryRepository.addRecentlySearchedQuery(.init(date: Date(), query: query))
        }
      }
      
      bibleSearchHistoryUseCase.addBibleSearchHistory(
        bibleRef: item.reference
      ) { result in
        switch result {
        case .success:
          observer.onNext(.none)
          observer.onCompleted()
        case .failure(let err):
          observer.onError(err)
        }
      }
      
      return Disposables.create()
    }
  }
}

// MARK: - BibleSearchResultViewAdapterDataSource
extension BibleSearchResultReactor: BibleSearchResultViewAdapterDataSource {
  public var searchResultNotFound: Bool {
    guard let lastQuery = currentState.lastQuery else { return false }
    return lastQuery != "" && currentState.isLoading == false && currentState.items.isEmpty
  }
  
  public var searchResult: String {
    currentState.lastQuery ?? ""
  }
  
  public var hasNextPage: Bool {
    (currentState.page + 1) * pageSize <= currentState.totalVerses
  }
  
  public var numberOfItems: Int {
    currentState.items.count
  }
  
  public func item(for indexPath: IndexPath) -> BibleVerseItem {
    currentState.items[indexPath.row]
  }
  
  public var isLoading: Bool {
    currentState.isLoading
  }
}
