//
//  BibleGardenCalendarHelperTests.swift
//  CoreTests
//
//  Created by 양승현 on 2/4/25.
//

import XCTest
import DomainEntity
import CoreInterface
@testable import Core

final class BibleGardenCalendarHelperTests: XCTestCase {
  let sut = CalendarService.shared
  
  func testIsSixWeeks() {
    /// Test for months with 6 weeks
    XCTAssertTrue(sut.isSixWeeks(year: 2025, month: 3))
    XCTAssertTrue(sut.isSixWeeks(year: 2025, month: 11))
    
    /// Test for months with 5 weeks
    XCTAssertFalse(sut.isSixWeeks(year: 2025, month: 1))
    XCTAssertFalse(sut.isSixWeeks(year: 2025, month: 2))
  }
  
  func testStartEndWeekdays() {
    /// Feb 2025는 금요일에 시작해 일요일에 끝나
    XCTAssertEqual(sut.startEndWeekdays(of: 2025, month: 2), WeekdayRange(start: .saturday, end: .friday))
    
    /// Jan 2025는 수욜부터 요일 시작하고 수요일에 요일 끝남
    XCTAssertEqual(sut.startEndWeekdays(of: 2025, month: 1), WeekdayRange(start: .wednesday, end: .friday))
  }
  
  /// Test specific months with known first weekdays
  func testFirstWeekday() {
    XCTAssertEqual(sut.firstWeekday(of: 2025, month: 1), .wednesday)
    XCTAssertEqual(sut.firstWeekday(of: 2025, month: 2), .saturday)
    XCTAssertEqual(sut.firstWeekday(of: 2025, month: 7), .tuesday)
  }
  
  /// Test for different months
  func testTotalDaysInMonth() {
    XCTAssertEqual(sut.totalDaysInMonth(year: 2025, month: 2), 28)
    XCTAssertEqual(sut.totalDaysInMonth(year: 2024, month: 2), 29)
    XCTAssertEqual(sut.totalDaysInMonth(year: 2025, month: 4), 30)
    XCTAssertEqual(sut.totalDaysInMonth(year: 2025, month: 8), 31)
  }

  func testToday() {
    // Simulate a specific date to test "today" method
    let stubToday = DateInfo(year: 2025, month: 2, day: 4, weekday: .tuesday)
    let stubDate = Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 4))!
    
    // Assuming you have a way to mock `CalendarHelper.today` or test it using the current date
    let today = sut.today(with: stubDate)
    
    XCTAssertEqual(today.year, stubToday.year)
    XCTAssertEqual(today.month, stubToday.month)
    XCTAssertEqual(today.day, stubToday.day)
    XCTAssertEqual(today.weekday, stubToday.weekday)
  }


}
