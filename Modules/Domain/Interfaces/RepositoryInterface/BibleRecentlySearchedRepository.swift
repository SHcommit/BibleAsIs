//
//  BibleRecentlySearchedRepository.swift
//  Domain
//
//  Created by 양승현 on 2/24/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol BibleRecentlySearchedQueryRepository {
  func addRecentlySearchedQuery(_ query: BibleRecentlySearchedQuery)
  func deleteRecentlySearchedQuery(_ query: BibleRecentlySearchedQuery)
  func fetchAllRecentlySearchedQueries() -> BibleRecentlySearchedQueries?
}
