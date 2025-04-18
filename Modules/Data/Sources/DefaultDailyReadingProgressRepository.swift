//
//  DefaultDailyReadingProgressRepository.swift
//  Data
//
//  Created by 양승현 on 3/3/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Common
import Foundation
import DomainEntity
import CoreInterface
import DomainInterface

public final class DefaultDailyReadingProgressRepository: DailyReadingProgressRepository {
  private let readingPlanKey = UserDefaultsKeys.dailyBibleReadingProgressEntry.forKey
  
  // MARK: - Dependencies
  private let fileStorage: UserStorageProtocol
  
  // MARK: - Lifecycle
  public init(fileStorage: UserStorageProtocol) {
    self.fileStorage = fileStorage
  }
  
  // MARK: - Helpers
  /// 이 경우는 먼저 클릭해서 칠하고,
  /// date선택해서 이 함수가 호출될 가능성이 있음
  public func increaseProgress(for book: BibleBook, chapter: Int) {
    var fetchedEntry = loadEntry()
    let today = getTodayDate()
    
    if fetchedEntry.firstReadingDate == nil {
      fetchedEntry.firstReadingDate = today
    }
    
    if !fetchedEntry.readDates.contains(today) {
      fetchedEntry.readDates.insert(today)
    }
    
    if fetchedEntry.readChapters[book] == nil {
      fetchedEntry.readChapters[book] = .init()
    }
    
    /// 이게 그 중복 +=1 되가지궁
    if fetchedEntry.readChapters[book]!.contains(chapter) == false {
      fetchedEntry.readChapters[book]?.insert(chapter)
      fetchedEntry.bookReadings[book]? += 1
      fetchedEntry.numberOfReadingBibleChapters += 1
      fileStorage.save(fetchedEntry, forKey: readingPlanKey)
    }
//    fetchedEntry.bookReadings[book]? += 1
//    fetchedEntry.numberOfReadingBibleChapters += 1
//    fileStorage.save(fetchedEntry, forKey: readingPlanKey)
  }
  
  public func decreaseProgress(for book: BibleBook, chapter: Int) throws {
    var fetchedEntry = loadEntry()
    if fetchedEntry.bookReadings[book] == 0 || fetchedEntry.numberOfReadingBibleChapters == 0 {
      throw makeUnexpectedDecrementError()
    }
    
    if fetchedEntry.readChapters[book] == nil {
      fetchedEntry.readChapters[book] = .init()
    }
    
    if fetchedEntry.readChapters[book]!.contains(chapter) == true {
      fetchedEntry.readChapters[book]?.remove(chapter)
      fetchedEntry.numberOfReadingBibleChapters -= 1
      fetchedEntry.bookReadings[book]? -= 1
      fileStorage.save(fetchedEntry, forKey: readingPlanKey)
      
    }
    
//    fetchedEntry.bookReadings[book]? -= 1
//    fetchedEntry.numberOfReadingBibleChapters -= 1
//    fileStorage.save(fetchedEntry, forKey: readingPlanKey)
  }
  
  public func fetchPercentage(for book: BibleBook) -> Double {
    let fetchedEntry = loadEntry()
    let currentValue = fetchedEntry.bookReadings[book] ?? 0
    var res = Double(Double(currentValue)/Double(book.numberOfChapters)*100.0)
    res = res > 100.0 ? 100.0 : res
    return res
  }
  
  public func fetchTotalReadChaptersPercentage() -> Double {
    let fetchedEntry = loadEntry()
    var res = Double(Double(fetchedEntry.numberOfReadingBibleChapters) / Double(BibleBook.allChapters) * 100.0)
    res = res > 100.0 ? 100.0 : res
    return res
  }
  
  /// yyyy-MM-dd format
  /// 맨 처음에 읽기 시작한 그 시간!
  public func fetchStartDate() -> Date? {
    loadEntry().firstReadingDate
  }
  
  /// 현재 연속 챌린지 진행 기간
  public func fetchContinuousChallengingDays() -> Int {
    loadEntry().continuousChallengingDays
  }
  
  /// 누적 최대 챌린지 진행 기간
  public func fetchMaxContinuousChallengingDays() -> Int {
    loadEntry().maxContinuousChallengingDays
  }
  
  /// 전체 읽은 챕터 수
  public func fetchTotalReadChapters() -> Int {
    let fetchedEntry = loadEntry()
    return fetchedEntry.numberOfReadingBibleChapters
  }
  
  /// 특정 성경 구조 카테고리 읽은 개수
  public func fetchBibleStructureReadingProgress(
    for category: BibleStructureCategory
  ) -> (readChapters: Int, totalChapters: Int) {
    let entry = loadEntry()
    let readchapters = entry.bookReadings.filter { $0.key.category == category }
      .map { $0.value }
      .reduce(0, +)
    let totalChapters = category.totalChapters
    
    return (readchapters, totalChapters)
  }
  
  /// 성경 구조별 읽은 총 챕터 개수
  public func fetchAllBibleStructureReadingProgress() -> [BibleStructureCategory: (readChapters: Int, totalChapters: Int)] {
    var progressByCategory: [BibleStructureCategory: (readChapters: Int, totalChapters: Int)] = [:]
    
    for category in BibleStructureCategory.allCases {
      progressByCategory[category] = fetchBibleStructureReadingProgress(for: category)
    }
    
    return progressByCategory

  }
}

// MARK: - Private Helpers
extension DefaultDailyReadingProgressRepository {
  private func loadEntry() -> DailyBibleReadingProgressEntry {
    let fetchedEntry = fileStorage.load(forKey: readingPlanKey, type: DailyBibleReadingProgressEntry.self)
    if fetchedEntry == nil {
      fileStorage.save(DailyBibleReadingProgressEntry(), forKey: readingPlanKey)
    }
    return fetchedEntry ?? DailyBibleReadingProgressEntry()
  }
  
  private func errorFactory(code: Int, errorMessage: String) -> NSError {
    return .init(
      domain: "com.journeyOfFaith.DailyBibleReadingRepository",
      code: code,
      userInfo: [NSLocalizedDescriptionKey: errorMessage])
  }
  
  private func makeUnexpectedDecrementError() -> NSError {
    return errorFactory(
      code: 1001, errorMessage: "데이터 저장 오류: 읽은 장(chapter)이 0 이하가 될 수 없습니다.")
  }
  
  // MARK: - related date Helpers
  /// 시간말고 날짜만!
  private func getTodayDate() -> Date {
    return Calendar.current.startOfDay(for: Date())
  }
}
