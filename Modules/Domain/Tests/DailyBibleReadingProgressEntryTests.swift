//
//  DailyBibleReadingProgressEntryTests.swift
//  DomainTests
//
//  Created by 양승현 on 3/5/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import XCTest
@testable import DomainEntity

final class DailyBibleReadingProgressEntryTests: XCTestCase {
  
  var sut: DailyBibleReadingProgressEntry!
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
    sut = nil
  }
  
  // MARK: - Tests
  /// 단일 날짜만 있을 경우 (현재 연속 1, 최대 연속 1)
  func test_singleDate() {
    let dates: Set<Date> = [dateFromString("2024-03-10")]
    sut = DailyBibleReadingProgressEntry(readDates: dates)
    
    XCTAssertEqual(sut.continuousChallengingDays, 1, "현재 연속 도전은 1일이어야 함")
    XCTAssertEqual(sut.maxContinuousChallengingDays, 1, "최대 연속 도전은 1일이어야 함")
  }
  
  /// 날짜가 연속되지 않는 경우 (현재 연속 1, 최대 연속 2)
  func test_nonContinuousDates() {
    let dates: Set<Date> = [
      dateFromString("2024-03-01"),
      dateFromString("2024-03-02"),
      dateFromString("2024-03-05"),
      dateFromString("2024-03-10")
    ]
    sut = DailyBibleReadingProgressEntry(readDates: dates)
    
    XCTAssertEqual(sut.continuousChallengingDays, 1, "현재 연속 도전은 1일이어야 함 (연속되지 않음)")
    XCTAssertEqual(sut.maxContinuousChallengingDays, 2, "최대 연속 도전은 2일이어야 함 (03-01~03-02)")
  }
  
  /// 최근 연속 도전 중 (현재 연속 3, 최대 연속 4)
  func test_recentContinuousChallenge() {
    let dates: Set<Date> = [
      dateFromString("2024-02-28"),
      dateFromString("2024-02-29"),
      dateFromString("2024-03-01"),
      dateFromString("2024-03-03"),
      dateFromString("2024-03-04"),
      dateFromString("2024-03-05")
    ]
    sut = DailyBibleReadingProgressEntry(readDates: dates)
    
    XCTAssertEqual(sut.continuousChallengingDays, 3, "현재 연속 도전은 3일이어야 함 (03-03~03-05)")
    XCTAssertEqual(sut.maxContinuousChallengingDays, 3, "최대 연속 도전은 4일이어야 함 (02-28~03-01)")
  }
  
  /// 완벽하게 연속된 날짜 (현재 연속 == 최대 연속)
  func test_fullyContinuousDates() {
    let dates: Set<Date> = [
      dateFromString("2024-02-25"),
      dateFromString("2024-02-26"),
      dateFromString("2024-02-27"),
      dateFromString("2024-02-28"),
      dateFromString("2024-02-29")
    ]
    sut = DailyBibleReadingProgressEntry(readDates: dates)
    
    XCTAssertEqual(sut.continuousChallengingDays, 5, "현재 연속 도전은 5일이어야 함")
    XCTAssertEqual(sut.maxContinuousChallengingDays, 5, "최대 연속 도전도 5일이어야 함")
  }
  
  /// 날짜가 없는 경우 (연속 도전 0)
  func test_emptyDates() {
    let dates: Set<Date> = []
    sut = DailyBibleReadingProgressEntry(readDates: dates)
    
    XCTAssertEqual(sut.continuousChallengingDays, 0, "현재 연속 도전은 0일이어야 함")
    XCTAssertEqual(sut.maxContinuousChallengingDays, 0, "최대 연속 도전도 0일이어야 함")
  }
  
  // MARK: - Helpers
  private func dateFromString(_ dateStr: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    return formatter.date(from: dateStr)!
  }
}
