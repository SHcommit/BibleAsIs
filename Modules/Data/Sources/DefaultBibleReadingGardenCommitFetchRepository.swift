//
//  DefaultBibleReadingGardenCommitFetchRepository.swift
//  Domain
//
//  Created by 양승현 on 3/18/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import BibleInterface
import DomainInterface

public final class DefaultBibleReadingGardenCommitFetchRepository: BibleReadingGardenCommitFetchRepository {
  // MARK: - Properties
  private let gardenCommitDAO: BibleReadingGardenCommitDAO
  
  private let backgroundQueue = DispatchQueue(label: "com.Domain.DefaultBibleReadingGardenCommitFetchRepository.queue")
  
  // MARK: - Lifecycle
  public init(gardenCommitDAO: BibleReadingGardenCommitDAO) {
    self.gardenCommitDAO = gardenCommitDAO
  }
  
  // MARK: - Helpers
  public func fetchMonthlyReadingGardenCommitHistories(
    in year: Int,
    month: Int,
    completion: @escaping (Result<[BibleDailyReadingEntry], any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { return }
      gardenCommitDAO.fetchBibleDailyReadingEntries(forYear: year, month: month) { entries in
        completion(.success(entries))
      }
    }
  }
  
  public func fetchAnnualReadingGardenCommitHistories(
    year: Int,
    completion: @escaping (Result<[[BibleDailyReadingEntry]], any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { return }
      gardenCommitDAO.fetchBibleDailyReadingEntriesGroupedByMonth(forYear: year) { entries in
        completion(.success(entries))
      }
    }
  }
}
