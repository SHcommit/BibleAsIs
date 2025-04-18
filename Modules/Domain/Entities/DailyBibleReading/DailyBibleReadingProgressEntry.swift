//
//  DailyBibleReadingProgressEntry.swift
//  DomainInterface
//
//  Created by 양승현 on 3/3/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public struct DailyBibleReadingProgressEntry: Codable {
  /// 책 별 읽은 챕터 개수 저장
  public var bookReadings: [BibleBook: Int]
  
  /// 책 별 읽은 챕터 저장
  public var readChapters: [BibleBook: Set<Int>]
  
  public var numberOfReadingBibleChapters: Int
  
  /// 이거 기반으로 이제 Continuous challneges
  public var readDates: Set<Date>
  
  /// 현재 몇퍼센트 진행중인지
  public var continuousChallengingDays: Int {
    calculateContinuousChallengingDays(dates: readDates)
  }
  
  public var maxContinuousChallengingDays: Int {
    calculateMaxContinuousChallengingDays(dates: readDates)
  }
  
  public var firstReadingDate: Date?
  
  public init(readDates: Set<Date> = Set()) {
    self.bookReadings = Dictionary(uniqueKeysWithValues: BibleBook.allBooks.map { ($0, 0) })
    self.numberOfReadingBibleChapters = 0
    self.readDates = readDates
    self.readChapters = .init()
  }
  
  private func calculateContinuousChallengingDays(dates: Set<Date>) -> Int {
    let sortedDates = dates.sorted()
    if sortedDates.isEmpty { return 0 }
    var currentStreak = 1
    
    guard sortedDates.last != nil else { return 0 }
    for i in (0..<sortedDates.count - 1).reversed() {
      let prevDate = sortedDates[i]
      let currentDate = sortedDates[i + 1]
      
      if Calendar.current.isDate(currentDate, inSameDayAs: prevDate.addingTimeInterval(86400)) {
        currentStreak += 1
      } else {
        break
      }
    }
    
    return currentStreak
  }
  
  private func calculateMaxContinuousChallengingDays(dates: Set<Date>) -> Int {
    let sortedDates = dates.sorted()
    if sortedDates.isEmpty { return 0 }
    
    var maxStreak = 1
    var currentStreak = 1
    
    for i in 1..<sortedDates.count {
      let prevDate = sortedDates[i - 1]
      let currentDate = sortedDates[i]
      
      if Calendar.current.isDate(currentDate, inSameDayAs: prevDate.addingTimeInterval(86400)) {
        currentStreak += 1
      } else {
        maxStreak = max(maxStreak, currentStreak)
        currentStreak = 1 // 다시 1일부터 시작
      }
    }
    
    return max(maxStreak, currentStreak)
  }
}
