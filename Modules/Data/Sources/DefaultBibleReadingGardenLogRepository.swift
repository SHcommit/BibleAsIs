//
//  DefaultBibleReadingGardenLogRepository.swift
//  Data
//
//  Created by 양승현 on 3/14/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import BibleInterface
import DomainInterface

public final class DefaultBibleReadingGardenLogRepository: BibleReadingGardenLogRepository {
  private let backgroundQueue = DispatchQueue(
    label: "com.bible.BibleReadingGardenLogRepository.queue",
    qos: .userInteractive)
  
  private let readingGardenLogDAO: BibleReadingGardenLogDAO
  
  // MARK: - Lifecycle
  public init(readingGardenLogDAO: BibleReadingGardenLogDAO) {
    self.readingGardenLogDAO = readingGardenLogDAO
  }

  // MARK: - Helpers
  public func fetchBibleReadingGardenLogCommitsForYear(
    year: Int,
    completion: @escaping (Result<[BibleReadingGardenLogEntry], any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      readingGardenLogDAO.fetchBibleReadingGardenLogCommitsForYear(year: year) { res in
        completion(.success(res))
      }
    }
  }
  
  public func fetchBibleReadingGardenLogCommitsForMomth(
    year: Int,
    month: Int,
    completion: @escaping (Result<[BibleReadingGardenLogEntry], any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      readingGardenLogDAO.fetchBibleReadingGardenLogCommitsForMomth(year: year, month: month) { res in
        completion(.success(res))
      }
    }
  }
  
  public func fetchBibleReadingGardenLogCommitsForDay(
    year: Int,
    month: Int,
    day: Int,
    completion: @escaping (Result<BibleReadingGardenLogEntry?, any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      readingGardenLogDAO.fetchBibleReadingGardenLogCommitsForDay(year: year, month: month, day: day) { entry in
        completion(.success(entry))
      }
    }
  }
  
  public func saveBibleReadingGardenForDay(
    _ newEntry: BibleReadingGardenLogEntry,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      readingGardenLogDAO.logBibleReadingGardenForDay(newEntry)
      completion(.success(()))
    }
  }
  
  public func didLogReadingOnDay(
    _ entry: BibleReadingGardenLogEntry,
    completion: @escaping (Result<Bool, any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      readingGardenLogDAO.didLogReadingOnDay(entry) { didLog in
        completion(.success(didLog))
      }
    }
  }
  
  public func delete(
    _ entry: BibleReadingGardenLogEntry,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      readingGardenLogDAO.delete(entry)
      completion(.success(()))
    }
  }
}
