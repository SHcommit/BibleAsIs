//
//  DailyBibleReadingChecklistUseCase.swift
//  DomainInterface
//
//  Created by 양승현 on 3/3/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol DailyBibleReadingChecklistUseCase {
  func fetchAlreadyReadEntries(
    book: BibleBook,
    completion: @escaping (Result<[DailyBibleReadingChapterEntry], any Error>) -> Void)
  
  /// 여기서 유저디폴츠 +1 or -1
  func update(
    _ entry: DailyBibleReadingChapterEntry,
    completion: @escaping (Result<Void, any Error>) -> Void)
  
  /// 여기서 유저디폴츠 +1
  func insert(
    _ entry: DailyBibleReadingChapterEntry,
    completion: @escaping (Result<Void, any Error>) -> Void)
  
  func fetchPercentage(for book: BibleBook, completion: @escaping (Result<Double, any Error>) -> Void)
  
  func fetchDailyReadingPlanTotalPercentage(completion: @escaping (Result<Double, any Error>) -> Void)
  
  /// yyyy-MM-dd format
  func fetchStartDate(completion: @escaping (Result<Date?, any Error>) -> Void)
  
  /// 연속 챌린지
  func fetchContinuousChallengingDays(completion: @escaping (Result<Int, any Error>) -> Void)
  
  /// 누적 최대 연속 챌린지
  func fetchMaxContinuousChallengingDays(completion: @escaping (Result<Int, any Error>) -> Void)
    
  /// 총 읽은 개수
  func fetchTotalReadChapters(completion: @escaping (Result<Int, any Error>) -> Void)
  
  func fetchAllBibleStructureReadingProgress(
    completion: @escaping (Result<[BibleStructureCategory: (readChapters: Int, totalChapters: Int)], any Error>) -> Void)
}
