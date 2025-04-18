//
//  DefaultBibleSearchHistoryUseCase.swift
//  Domain
//
//  Created by 양승현 on 2/24/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import DomainInterface

public final class DefaultBibleSearchHistoryUseCase: BibleSearchHistoryUseCase {
  // MARK: - Properties
  private let bibleRepository: BibleRepository
  
  // MARK: - Lifecycle
  public init(bibleRepository: BibleRepository) {
    self.bibleRepository = bibleRepository
  }
  
  public func addBibleSearchHistory(
    bibleRef ref: DomainEntity.BibleReference,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    bibleRepository.addBibleSearchHistory(bibleRef: ref, completion: completion)
  }
  
  public func fetchAllGroupedSearchHistory(
    completion: @escaping (Result<[[BibleSearchHistory]], any Error>) -> Void
  ) {
    bibleRepository.fetchAllGroupedSearchHistory(completion: completion)
  }
  
  public func deleteBibleSearchHistories(
    forYear year: String,
    month: String,
    day: String,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    bibleRepository.deleteBibleSearchHistories(forYear: year, month: month, day: day, completion: completion)
  }
}
