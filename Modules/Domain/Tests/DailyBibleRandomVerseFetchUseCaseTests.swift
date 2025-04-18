//
//  DailyBibleRandomVerseFetchUseCaseTests.swift
//  DomainTests
//
//  Created by 양승현 on 3/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import XCTest
@testable import Domain
@testable import DomainEntity
@testable import DomainInterface

final class DailyBibleRandomVerseFetchUseCaseTests: XCTestCase {
  var sut: DefaultDailyBibleRandomVerseFetchUseCase!
  var mockBibleRepository: MockBibleRepository!
  var mockDailyBibleRandomVerseFetchRepository: MockDailyBibleRandomVerseFetchRepository!
  
  override func setUp() {
    super.setUp()
    mockBibleRepository = MockBibleRepository()
    mockDailyBibleRandomVerseFetchRepository = MockDailyBibleRandomVerseFetchRepository()
    sut = DefaultDailyBibleRandomVerseFetchUseCase(
      bibleRepository: mockBibleRepository,
      bibleRandomVerseFetchRepository: mockDailyBibleRandomVerseFetchRepository
    )
  }
  
  override func tearDown() {
    sut = nil
    mockBibleRepository = nil
    mockDailyBibleRandomVerseFetchRepository = nil
    super.tearDown()
  }
  
  // MARK: - Test Single Random Verse
  func test_fetchRandomVerse_day1_returnsExpectedVerses() {
    let expectation = self.expectation(description: "Fetch Random Verse for day 1")
    
    sut.fetchRandomVerse(day: 1) { result in
      switch result {
      case .success(let verses):
        XCTAssertEqual(verses.count, 2, "Day 1의 구절 개수는 2개여야 함")
        
        let expectedVerses = [
          BibleVerse(book: .firstChronicles, chapter: 29, verse: 11, content: "Mocked Content 1"),
          BibleVerse(book: .firstChronicles, chapter: 29, verse: 12, content: "Mocked Content 2")
        ]
        
        XCTAssertEqual(verses, expectedVerses, "조회된 성경 구절이 예상된 값과 일치해야 함")
        print("fetchRandomVerse 유즈케이스에서 테스트한거 \n 반환된 구절: \(verses)")
      case .failure(let error):
        XCTFail("테스트 실패: \(error)")
      }
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 2.0)
  }
  
  // MARK: - Test Weekly Random Verses
  func test_fetchWeeklyRandomVerses_fromDay1_returnsExpectedVerses() {
    let expectation = self.expectation(description: "Fetch Weekly Random Verses from day 1")
    
    sut.fetchWeeklyRandomVerses(fromDay: 1) { result in
      switch result {
      case .success(let weeklyVerses):
        XCTAssertEqual(weeklyVerses.count, 7, "7일치 구절이 반환되어야 함")
        
        let expectedFirstBooks: [BibleBook] = [
          .firstChronicles, .daniel, .psalms, .psalms, .firstTimothy, .isaiah, .romans]
        let fetchedDays = weeklyVerses.compactMap { $0.first?.book }
        
        XCTAssertEqual(fetchedDays, expectedFirstBooks, "조회된 day 순서가 예상된 값과 일치해야 함")
        print("fetchWeeklyRandomVerses in bible random verse fetch useCase. \n 반환된 days: \(fetchedDays)")
      case .failure(let error):
        XCTFail("테스트 실패: \(error)")
      }
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5.0)
  }
}
