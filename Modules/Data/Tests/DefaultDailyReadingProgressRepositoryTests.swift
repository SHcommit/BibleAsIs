//
//  DefaultDailyReadingProgressRepositoryTests.swift
//  DataTests
//
//  Created by 양승현 on 3/3/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import XCTest
@testable import DomainEntity
@testable import Data

final class DefaultDailyReadingProgressRepositoryTests: XCTestCase {
  var sut: DefaultDailyReadingProgressRepository!
  var mockStorage: MockUserStorage!
  
  override func setUp() {
    super.setUp()
    mockStorage = MockUserStorage()
    sut = DefaultDailyReadingProgressRepository(fileStorage: mockStorage)
  }
  
  override func tearDown() {
    sut = nil
    mockStorage = nil
    super.tearDown()
  }
  
  func testIncreaseProgress() {
    let book = BibleBook.genesis
    
    sut.increaseProgress(for: book, chapter: 1)
    var progress = sut.fetchPercentage(for: book)
    XCTAssertEqual(progress, (1.0 / Double(book.numberOfChapters)) * 100, "1장 증가 후 퍼센트 계산 실패")
    
    sut.increaseProgress(for: book, chapter: 2)
    progress = sut.fetchPercentage(for: book)
    XCTAssertEqual(progress, (2.0 / Double(book.numberOfChapters)) * 100, "2장 증가 후 퍼센트 계산 실패")
  }
  
  func testDuplicatedIncreaseProgress() {
    let book = BibleBook.genesis
    
    sut.increaseProgress(for: book, chapter: 1)
    sut.increaseProgress(for: book, chapter: 1)
    sut.increaseProgress(for: book, chapter: 1)
    sut.increaseProgress(for: book, chapter: 1)
    sut.increaseProgress(for: book, chapter: 1)
    
    do {
      try sut.decreaseProgress(for: book, chapter: 1)
    } catch {
      print(" 에러발생 \(error)")
      XCTFail()
    }
    XCTAssertEqual(sut.fetchPercentage(for: book), 0.0)
    XCTAssertEqual(sut.fetchTotalReadChapters(), 0)
  }
  
  func testDecreaseProgress() throws {
    /// Assert
    let book = BibleBook.genesis
    sut.increaseProgress(for: book, chapter: 1)
    sut.increaseProgress(for: book, chapter: 2)
    
    /// Act
    try sut.decreaseProgress(for: book, chapter: 2)
    let progress = sut.fetchPercentage(for: book)
    XCTAssertEqual(progress, (1.0 / Double(book.numberOfChapters)) * 100, "1장 감소 후 퍼센트 계산 실패")
    
    try sut.decreaseProgress(for: book, chapter: 1)
    
    /// 읽은 개수 0 장 일 때 감소되는 경우.. ( 정말 거의 없음 아예 안될듯 )
    XCTAssertThrowsError(try sut.decreaseProgress(for: book, chapter: 1)) { error in
      XCTAssertEqual((error as NSError).code, 1001, "0장 이하로 감소하면 에러 발생해야 함")
    }
  }
  
  func testFetchTotalReadChaptersPercentage() {
    let book1 = BibleBook.genesis
    let book2 = BibleBook.john
    
    sut.increaseProgress(for: book1, chapter: 1)
    sut.increaseProgress(for: book1, chapter: 2)
    sut.increaseProgress(for: book2, chapter: 3)
    
    let expectedTotalPercentage = (3.0 / Double(BibleBook.allChapters)) * 100
    let totalPercentage = sut.fetchTotalReadChaptersPercentage()
    
    XCTAssertEqual(totalPercentage, expectedTotalPercentage, accuracy: 0.1, "전체 퍼센트 계산 실패")
  }
}
