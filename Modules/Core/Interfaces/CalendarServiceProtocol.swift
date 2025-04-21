//
//  CalendarServiceProtocol.swift
//  CoreInterface
//
//  Created by 양승현 on 2/3/25.
//

import Foundation
import DomainEntity

public protocol CalendarServiceProtocol {
  
  func startEndWeekdays(of year: Int, month: Int) -> WeekdayRange
  func firstWeekday(of year: Int, month: Int) -> Weekday
  func totalDaysInMonth(year: Int, month: Int) -> Int
  func today(with date: Date) -> DateInfo
  
  /// 주로 BibleReadingGarden에서 쓰임
  func getTodayComponents() -> DateComponents
  func isDateToday(year: Int, month: Int, day: Int) -> Bool
  func isCurrentMonth(year: Int, month: Int) -> Bool
  
  /// 주로 Garden에서 쓰임
  func isSixWeeks(year: Int, month: Int) -> Bool
  
  /// 년월일을 1에서 365일 중 하나로 윤년은 처리 안함
  func toDayIndex(from dateComponents: DateComponents) -> Int
  
  /// 오늘의 년월일을 1에서 365일 중 하나로 윤년은 처리 안함
  func currentTodayIndex() -> Int

}
