//
//  CalendarService.swift
//  Core
//
//  Created by 양승현 on 2/3/25.
//

import Foundation
import DomainEntity
import CoreInterface

public struct CalendarService: CalendarServiceProtocol {
  private let calendar = Calendar(identifier: .gregorian)
  
  private init () { }
  
  public static let shared = Self()
  
  public func isSixWeeks(year: Int, month: Int) -> Bool {
    let firstWeekday = firstWeekday(of: year, month: month).day
    let totalDays = totalDaysInMonth(year: year, month: month)
    
    let totalCells = firstWeekday + totalDays
    return totalCells > 35 /// 7 * 5 ( 5 주 )
  }
  
  /// 특정 year, month가 현재 날짜의 year, month와 같은지 여부 반환 ㅇㅅㅇ
  public func isCurrentMonth(year: Int, month: Int) -> Bool {
    let currentDate = Date()
    let currentYear = calendar.component(.year, from: currentDate)
    let currentMonth = calendar.component(.month, from: currentDate)
    return year == currentYear && month == currentMonth
  }
  
  /// 특정 month의 시작 일 및 마지막 일 index 반환
  public func startEndWeekdays(of year: Int, month: Int) -> WeekdayRange {
    let firstWeekday = firstWeekday(of: year, month: month)
    let totalDays = totalDaysInMonth(year: year, month: month)
    let lastWeekday = (firstWeekday.day + totalDays - 1) % 7
    return WeekdayRange(
      start: Weekday(rawValue: firstWeekday.day) ?? .sunday,
      end: Weekday(rawValue: lastWeekday) ?? .sunday)
  }
  
  /// 특정 달의 첫 요일 (0=일, 1=월, 화 = 2, 수 = 3 목 = 4 금 = 5, 6=토)
  public func firstWeekday(of year: Int, month: Int) -> Weekday {
    let components = DateComponents(year: year, month: month, day: 1)
    let date = calendar.date(from: components).map { calendar.component(.weekday, from: $0) - 1 } ?? 0
    return Weekday(rawValue: date) ?? .sunday
  }
  
  /// 특정 달의 총 일수 반환
  public func totalDaysInMonth(year: Int, month: Int) -> Int {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = 1
    
    guard
      let date = calendar.date(from: components),
      let range = calendar.range(of: .day, in: .month, for: date)
    else { return 30 }
    
    return range.count
  }
  
  public func today(with date: Date = Date()) -> DateInfo {
    let now = date
    let calendar = Calendar.current
    let year = calendar.component(.year, from: now)
    let month = calendar.component(.month, from: now)
    /// 특정한 요일 (e.g. 금요일)
    let day = calendar.component(.day, from: now)
    /// 일(0) ~ 토(6)
    let weekday = calendar.component(.weekday, from: now) - 1
    return .init(year: year, month: month, day: day, weekday: Weekday(rawValue: weekday) ?? .sunday)
  }
  
  /// year, month, day를 반환
  public func getTodayComponents() -> DateComponents {
    return calendar.dateComponents([.year, .month, .day], from: Date())
  }
  
  public func isDateToday(year: Int, month: Int, day: Int) -> Bool {
    let today = getTodayComponents()
    return today.year == year && today.month == month && today.day == day
  }
  
  /// 년월일을 1에서 365일 중 하나로 윤년은 처리 안함
  public func toDayIndex(from dateComponents: DateComponents) -> Int {
    guard
      let year = dateComponents.year,
      let month = dateComponents.month,
      let day = dateComponents.day,
      let date = calendar.date(from: DateComponents(year: year, month: month, day: day))
    else {
      return 1
    }
    
    return calendar.ordinality(of: .day, in: .year, for: date) ?? 1
  }
  
  /// 오늘의 년월일을 1에서 365일 중 하나로 윤년은 처리 안함
  public func currentTodayIndex() -> Int {
    let todayComponents = getTodayComponents()
    return toDayIndex(from: todayComponents)
  }
}
