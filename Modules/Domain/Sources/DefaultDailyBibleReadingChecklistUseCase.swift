//
//  DefaultDailyBibleReadingChecklistUseCase.swift
//  Domain
//
//  Created by 양승현 on 3/3/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import DomainInterface

public final class DefaultDailyBibleReadingChecklistUseCase: DailyBibleReadingChecklistUseCase {
  // MARK: - Dependencies
  private let dailyReadingChecklistRepository: DailyReadingChecklistRepository
  
  private let dailyReadingProgressRepository: DailyReadingProgressRepository
  
  // MARK: - Lifecycle
  public init(
    dailyReadingChecklistRepository: DailyReadingChecklistRepository,
    dailyReadingProgressRepository: DailyReadingProgressRepository
  ) {
    self.dailyReadingChecklistRepository = dailyReadingChecklistRepository
    self.dailyReadingProgressRepository = dailyReadingProgressRepository
  }
  
  // MARK: - Helpers
  public func fetchAlreadyReadEntries(
    book: BibleBook,
    completion: @escaping (Result<[DailyBibleReadingChapterEntry], any Error>) -> Void
  ) {
    dailyReadingChecklistRepository.fetchAlreadyReadEntries(book: book, completion: completion)
  }
  
  /// Depreciate
  /// @available(*, deprecated, renamed: "이거대신 insert로", message: "뀨")
  public func update(
    _ entry: DailyBibleReadingChapterEntry,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    
    if entry.alreadyRead {
      dailyReadingProgressRepository.increaseProgress(for: entry.book, chapter: entry.chapter)
    } else {
      do {
        try dailyReadingProgressRepository.decreaseProgress(for: entry.book, chapter: entry.chapter)
      } catch {
        completion(.failure(error))
      }
    }
    dailyReadingChecklistRepository.update(entry, completion: completion)
  }
  
  public func insert(
    _ entry: DailyBibleReadingChapterEntry,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    if entry.alreadyRead {
      dailyReadingProgressRepository.increaseProgress(for: entry.book, chapter: entry.chapter)
    } else {
      do {
        try dailyReadingProgressRepository.decreaseProgress(for: entry.book, chapter: entry.chapter)
      } catch {
        completion(.failure(error))
      }
    }
//    dailyReadingProgressRepository.increaseProgress(for: entry.book)
    dailyReadingChecklistRepository.insert(entry, completion: completion)
  }
  
  public func fetchPercentage(
    for book: BibleBook,
    completion: @escaping (Result<Double, any Error>) -> Void
  ) {
    let percentage = dailyReadingProgressRepository.fetchPercentage(for: book)
    completion(.success(percentage))
  }
  
  public func fetchDailyReadingPlanTotalPercentage(
    completion: @escaping (Result<Double, any Error>) -> Void
  ) {
    let totalReadedChaptersPerecantage = dailyReadingProgressRepository.fetchTotalReadChaptersPercentage()
    completion(.success(totalReadedChaptersPerecantage))
  }
  
  public func fetchStartDate(completion: @escaping (Result<Date?, any Error>) -> Void) {
    completion(.success(dailyReadingProgressRepository.fetchStartDate()))
  }
  
  public func fetchContinuousChallengingDays(completion: @escaping (Result<Int, any Error>) -> Void) {
    completion(.success(dailyReadingProgressRepository.fetchContinuousChallengingDays()))
  }
  
  public func fetchMaxContinuousChallengingDays(completion: @escaping (Result<Int, any Error>) -> Void) {
    completion(.success(dailyReadingProgressRepository.fetchMaxContinuousChallengingDays()))
  }
  
  public func fetchTotalReadChapters(completion: @escaping (Result<Int, any Error>) -> Void) {
    completion(.success(dailyReadingProgressRepository.fetchTotalReadChapters()))
  }
  
  public func fetchAllBibleStructureReadingProgress(
    completion: @escaping (Result<[BibleStructureCategory: (readChapters: Int, totalChapters: Int)], any Error>) -> Void
  ) {
    completion(.success(dailyReadingProgressRepository.fetchAllBibleStructureReadingProgress()))
  }
}
