//
//  DailyReadingProgressRepository.swift
//  DomainInterface
//
//  Created by 양승현 on 3/3/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol DailyReadingProgressRepository {
  func increaseProgress(for book: BibleBook, chapter: Int)
  func decreaseProgress(for book: BibleBook, chapter: Int) throws
  
  func fetchPercentage(for book: BibleBook) -> Double
  func fetchTotalReadChaptersPercentage() -> Double
  
  /// yyyy-MM-dd format
  func fetchStartDate() -> Date?
  
  func fetchContinuousChallengingDays() -> Int
  
  func fetchMaxContinuousChallengingDays() -> Int
  
  func fetchTotalReadChapters() -> Int
  
  func fetchBibleStructureReadingProgress(
    for category: BibleStructureCategory
  ) -> (readChapters: Int, totalChapters: Int)
  
  func fetchAllBibleStructureReadingProgress() -> [BibleStructureCategory: (readChapters: Int, totalChapters: Int)]
}
