//
//  StubBibleRecentlySearchedQueryRepository.swift
//  BibleSearchFeature
//
//  Created by 양승현 on 2/25/25.
//

import Foundation
import DomainEntity
import DomainInterface

final class StubBibleRecentlySearchedQueryRepository: BibleRecentlySearchedQueryRepository {
  func addRecentlySearchedQuery(_ query: DomainEntity.BibleRecentlySearchedQuery) {
  }
  
  func deleteRecentlySearchedQuery(_ query: DomainEntity.BibleRecentlySearchedQuery) {
  }
  
  func fetchAllRecentlySearchedQueries() -> DomainEntity.BibleRecentlySearchedQueries? { return nil }
}
