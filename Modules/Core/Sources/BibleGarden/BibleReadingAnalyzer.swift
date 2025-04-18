//
//  BibleReadingAnalyzer.swift
//  Core
//
//  Created by 양승현 on 2/3/25.
//

import Foundation
import DomainEntity
import CoreInterface

public struct BibleReadingAnalyzer: BibleReadingAnalyzable {
  // MARK: - Properties
  private let calendarService: CalendarServiceProtocol
  
  // MARK: - Lifecycle
  public init(calendarService: CalendarServiceProtocol) {
    self.calendarService = calendarService
  }
  
  // MARK: - Helpers
  /// 1. 5주인지 6주인지 파악하기
  /// 2. 기본값 .hidden
  /// 3. 해당 monthe의 시작요일부터 끝 요일까지 .none처리
  /// 4. 데이터베이스에서 불러와서 해당 요일에 작성된거
  public func makeBibleGardenHitmap(
    for year: Int,
    month: Int,
    byReadingGardens readingGardens: [BibleDailyReadingEntry]
  ) -> [[BibleGardenLevel]] {
    let numberOfWeeks = calendarService.isSixWeeks(year: year, month: month) ? 6 : 5
    let weekdayRange = calendarService.startEndWeekdays(of: year, month: month)
    let startWeekday = weekdayRange.start.day
    let endWeekday = weekdayRange.end.day
    var hitmap: [[BibleGardenLevel]] = Array(
      repeating: Array(repeating: .none, count: 7),
      count: numberOfWeeks)
    
    /// 시작 전, 끝 이후 hidden 처리
    for i in 0..<startWeekday { hitmap[0][i] = .hidden }
    for i in (endWeekday+1)..<7 { hitmap[numberOfWeeks-1][i] = .hidden }
    
    for reading in readingGardens {
      let dayIndex = reading.day - 1
      let row = (dayIndex + startWeekday) / 7
      let col = (dayIndex + startWeekday) % 7
      
      hitmap[row][col] = BibleGardenLevel.level(for: reading.numberOfReadingChapters)
    }
    return hitmap
  }
}
