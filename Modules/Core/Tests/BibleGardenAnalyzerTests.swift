//
//  BibleGardenAnalyzerTests.swift
//  CoreTests
//
//  Created by 양승현 on 2/4/25.
//

import CoreInterface
import DomainEntity
@testable import Core
import XCTest

class MockCalendarService: CalendarServiceProtocol {
  func today(with date: Date) -> DomainEntity.DateInfo {
    .init(year: 1, month: 1, day: 1, weekday: .friday)
  }
  
  func getTodayComponents() -> DateComponents {
    .init()
  }
  
  func isDateToday(year: Int, month: Int, day: Int) -> Bool {
    true
  }
  
  func isCurrentMonth(year: Int, month: Int) -> Bool {
    true
  }
  
  func toDayIndex(from dateComponents: DateComponents) -> Int {
    1
  }
  
  func currentTodayIndex() -> Int {
    1
  }
  
  func startEndWeekdays(of year: Int, month: Int) -> WeekdayRange {
    if year == 2025, month == 2 {
      return WeekdayRange(start: .saturday, end: .friday)
    } else if year == 2025, month == 3 {
      return .init(start: .saturday, end: .monday)
    }
    return .init(start: .friday, end: .friday)
  }
  
  func firstWeekday(of year: Int, month: Int) -> Weekday {
    if year == 2025, month == 2 {
      return .saturday
    } else if year == 2025, month ==  3 {
      return .saturday
    }
    return .sunday
  }
  
  func totalDaysInMonth(year: Int, month: Int) -> Int {
    if year == 2025, month == 2 {
      return 28
    }
    if year == 2025, month == 3 {
      return 31
    }
    return 0
  }
  
  func isSixWeeks(year: Int, month: Int) -> Bool {
    if year == 2025, month == 2 {
      return false
    } else if year == 2025, month == 3 {
      return true
    }
    return false
  }
}


final class BibleGardenAnalyzerTests: XCTestCase {
  var sut: BibleReadingAnalyzable!
  
  var calendarService: MockCalendarService!
  
  override func setUp() {
    super.setUp()
    calendarService = MockCalendarService()
    sut = BibleReadingAnalyzer(calendarService: calendarService)
  }
  
  func testMakeBibleGardenHitmapForFiveWeeks() {
    //. Arrange
    let readingGardens: [BibleDailyReadingEntry] = [
      BibleDailyReadingEntry(year: 2025, month: 2, day: 1, numberOfReadingChapters: 1),
      BibleDailyReadingEntry(year: 2025, month: 2, day: 2, numberOfReadingChapters: 10),
      BibleDailyReadingEntry(year: 2025, month: 2, day: 3, numberOfReadingChapters: 20)
    ]
    
    /// Act
    let hitmap = sut.makeBibleGardenHitmap(for: 2025, month: 2, byReadingGardens: readingGardens)
    
    /// Assert
    for y in (0..<hitmap.count) {
      var str = ""
      for x in (0..<hitmap[0].count) {
        str += "\(hitmap[y][x]) "
      }
      print(str)
    }
    typealias LV = BibleGardenLevel
    XCTAssertEqual(hitmap[0][0], .hidden)
    XCTAssertEqual(hitmap[0][6], LV.level(for: 1))
    XCTAssertEqual(hitmap[1][0], LV.level(for: 10))
    XCTAssertEqual(hitmap[1][1], LV.level(for: 20))
  }
  
  /// 6주
  func testMakeBibleGardenHitmapForFixWeekks() {
    /// Arrange
    let readingGardens: [BibleDailyReadingEntry] = [
      BibleDailyReadingEntry(year: 2025, month: 3, day: 1, numberOfReadingChapters: 1),
      BibleDailyReadingEntry(year: 2025, month: 3, day: 2, numberOfReadingChapters: 16),
      BibleDailyReadingEntry(year: 2025, month: 3, day: 5, numberOfReadingChapters: 2),
      BibleDailyReadingEntry(year: 2025, month: 3, day: 13, numberOfReadingChapters: 7),
      BibleDailyReadingEntry(year: 2025, month: 3, day: 20, numberOfReadingChapters: 14)
    ]
    
    /// Act
    let hitmap = sut.makeBibleGardenHitmap(for: 2025, month: 3, byReadingGardens: readingGardens)
    
    /// Assert
    for y in (0..<hitmap.count) {
      var str = ""
      for x in (0..<hitmap[0].count) {
        str += "\(hitmap[y][x]) "
      }
      print(str)
    }
    
    typealias LV = BibleGardenLevel
    XCTAssertEqual(hitmap[0][3], .hidden)
    XCTAssertEqual(hitmap[0][6], LV.level(for: 1))
    XCTAssertEqual(hitmap[1][0], LV.level(for: 16))
    
    XCTAssertEqual(hitmap[1][3], LV.level(for: 2))
    XCTAssertEqual(hitmap[2][4], LV.level(for: 7))
    XCTAssertEqual(hitmap[3][4], LV.level(for: 14))
  }
}
