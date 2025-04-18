//
//  DefaultBibleRecentlySearchedQueryRepositoryTests.swift
//  DataTests
//
//  Created by 양승현 on 2/24/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import XCTest
import DomainEntity
import DomainInterface
import CoreInterface
import Common
@testable import Data

final class DefaultBibleRecentlySearchedQueryRepositoryTests: XCTestCase {
  var fakeUserDefaults: UserStorageProtocol!
  
  var sut: BibleRecentlySearchedQueryRepository!
  
  override func setUp() {
    super.setUp()
    fakeUserDefaults = FakeUserStorage()
    sut = DefaultBibleRecentlySearchedQueryRepository(storage: fakeUserDefaults)
  }
  
  override func tearDown() {
    super.tearDown()
    sut = nil
    fakeUserDefaults = nil
  }
}

extension DefaultBibleRecentlySearchedQueryRepositoryTests {
  func testInitialInsert() {
    let query = BibleRecentlySearchedQuery(date: Date(), query: "Query 1")
    sut.addRecentlySearchedQuery(query)
    
    let fetchedQueries = sut.fetchAllRecentlySearchedQueries()?.queries
    XCTAssertNotNil(fetchedQueries, "조회 결과는 nil이 아니어야 함")
    XCTAssertEqual(fetchedQueries?.count, 1, "최초 추가 후 1건이어야 함")
    XCTAssertEqual(fetchedQueries?.first?.query, "Query 1", "첫번째 쿼리는 'Query 1'이어야 함")
  }
  
  func testInsertLessThanMax() {
    for i in 1...5 {
      let query = BibleRecentlySearchedQuery(date: Date(), query: "Query \(i)")
      sut.addRecentlySearchedQuery(query)
    }
    
    let fetchedQueries = sut.fetchAllRecentlySearchedQueries()?.queries
    XCTAssertNotNil(fetchedQueries)
    print(fetchedQueries!)
    XCTAssertEqual(fetchedQueries?.count, 5, "총 5건이어야 함")
    XCTAssertEqual(fetchedQueries?.first?.query, "Query 5", "최신 쿼리는 'Query 5'이어야 함")
  }
  
  func testExceedMaxCount() {
    for i in 1...25 {
      let query = BibleRecentlySearchedQuery(date: Date(), query: "Query \(i)")
      sut.addRecentlySearchedQuery(query)
    }
    
    let fetchedQueries = sut.fetchAllRecentlySearchedQueries()?.queries
    XCTAssertNotNil(fetchedQueries)
    XCTAssertEqual(
      fetchedQueries?.count,
      BibleRecentlySearchedQuery.maxSavedQueryCounts,
      "최대 \(BibleRecentlySearchedQuery.maxSavedQueryCounts)건이어야 함")
    
    // 가장 최신 쿼리는 "Query 25"가 되어야 하고, 가장 오래된 것은 "Query 6"이어야 함
    XCTAssertEqual(fetchedQueries?.first?.query, "Query 25", "최신 쿼리는 'Query 25'이어야 함")
    XCTAssertEqual(fetchedQueries?.last?.query, "Query 6", "가장 오래된 쿼리는 'Query 6'이어야 함")
  }
}
