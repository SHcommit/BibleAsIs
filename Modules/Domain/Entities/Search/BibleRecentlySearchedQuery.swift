//
//  BibleRecentlySearchedQuery.swift
//  Domain
//
//  Created by 양승현 on 2/24/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public struct BibleRecentlySearchedQuery: Codable, Equatable, PrettyDebugStringConvertible {
  public static let maxSavedQueryCounts = 20
  public let date: Date
  public let query: String
  
  public init(date: Date, query: String) {
    self.date = date
    self.query = query
  }
}

public struct BibleRecentlySearchedQueries: Codable, PrettyDebugStringConvertible {
  public var queries: [BibleRecentlySearchedQuery]
  
  public init(queries: [BibleRecentlySearchedQuery]) {
    self.queries = queries
  }
  
  public mutating func insert(_ query: BibleRecentlySearchedQuery) {
    queries.insert(query, at: 0)
  }
  
  public mutating func removeLast() {
    queries.removeLast()
  }
  
  public mutating func remove(query: BibleRecentlySearchedQuery) {
    if let index = queries.firstIndex(where: { $0 == query}) {
      queries.remove(at: index)
    }
  }
}
