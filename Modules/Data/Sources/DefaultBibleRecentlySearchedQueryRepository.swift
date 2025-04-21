//
//  DefaultBibleRecentlySearchedQueryRepository.swift
//  Data
//
//  Created by 양승현 on 2/24/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Common
import Foundation
import DomainEntity
import DomainInterface
import CoreInterface

/// 최근 검색어는 20개 까지만 저장!
public final class DefaultBibleRecentlySearchedQueryRepository: BibleRecentlySearchedQueryRepository {
  internal typealias Keys = UserDefaultsKeys
  
  // MARK: - Properties
  private let storage: UserStorageProtocol
  
  // MARK: - Lifecycle
  public init(storage: UserStorageProtocol) {
    self.storage = storage
  }
  
  // MARK: - Helpers
  /// 성공 true, 실패 nil
  ///
  /// 여기서 중요한거는.. 쿼리 삭제할떄 queries 삭제 후 꼭 storage에
  /// 넣어주어야 한다는 것이다! !!!!
  public func addRecentlySearchedQuery(_ query: BibleRecentlySearchedQuery) {
    guard var queries = fetchAllRecentlySearchedQueries() else {
      /// 거의 최초에 한번만 실행
      let queries = BibleRecentlySearchedQueries.init(queries: [query])
      storage.save(queries, forKey: Keys.recentlySearchedBibleQueriesKey)
      return
    }
    
    if queries.queries.count == BibleRecentlySearchedQuery.maxSavedQueryCounts {
      queries.removeLast()
      queries.insert(query)
      storage.save(queries, forKey: Keys.recentlySearchedBibleQueriesKey)
      return
    }
    
    queries.insert(query)
    storage.save(queries, forKey: Keys.recentlySearchedBibleQueriesKey)
  }
  
  public func deleteRecentlySearchedQuery(_ query: BibleRecentlySearchedQuery) {
    guard var queries = fetchAllRecentlySearchedQueries() else { return }
    
    queries.remove(query: query)
    storage.save(queries, forKey: Keys.recentlySearchedBibleQueriesKey)
  }
  
  public func fetchAllRecentlySearchedQueries() -> BibleRecentlySearchedQueries? {
    storage.load(
      forKey: Keys.recentlySearchedBibleQueriesKey,
      type: BibleRecentlySearchedQueries.self)
  }
}
