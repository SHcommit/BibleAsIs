//
//  DefaultDailyBibleRandomVerseFetchRepository.swift
//  Data
//
//  Created by 양승현 on 3/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import BibleInterface
import DomainInterface

public final class DefaultDailyBibleRandomVerseFetchRepository: DailyBibleRandomVerseFetchRepository {
  // MARK: - Dependencies
  private let dailyBibleRandomVerseDAO: DailyBibleRandomVerseDAO
  
  // MARK: - Lifecycle
  public init(dailyBibleRandomVerseDAO: DailyBibleRandomVerseDAO) {
    self.dailyBibleRandomVerseDAO = dailyBibleRandomVerseDAO
  }
  
  // MARK: - Helpers
  public func fetchRandomVerse(
    day: Int,
    completion: @escaping (Result<[DailyRandomVerseEntity], any Error>) -> Void
  ) {
    dailyBibleRandomVerseDAO.fetchRandomVerse(day: day) { entries in
      completion(.success(entries.map { DailyRandomVerseDTO(from: $0).toDomain() }))
    }
  }
  
  public func fetchWeeklyRandomVerses(fromDay: Int, completion: @escaping (Result<[[DomainEntity.DailyRandomVerseEntity]], any Error>) -> Void) {
    dailyBibleRandomVerseDAO.fetchWeeklyRandomVerses(fromDay: fromDay) { entriesArray in
      completion(.success(entriesArray.map { arr in
        return arr.map { DailyRandomVerseDTO(from: $0).toDomain() }
      }))
    }
  }
}
