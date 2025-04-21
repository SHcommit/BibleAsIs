//
//  DefaultBibleReadingGardenDeleteUseCase.swift
//  DomainEntity
//
//  Created by 양승현 on 3/14/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import DomainInterface

public final class DefaultBibleReadingGardenDeleteUseCase: BibleReadingGardenDeleteUseCase {
  // MARK: - Dependencies
  private let tracker: BibleReadingGardenTrackable
  
  private let gardenLogRepository: BibleReadingGardenLogRepository
  
  // MARK: - Lifecycle
  public init(
    tracker: BibleReadingGardenTrackable,
    gardenLogRepository: BibleReadingGardenLogRepository
  ) {
    self.tracker = tracker
    self.gardenLogRepository = gardenLogRepository
  }
  
  // MARK: - Helpers
  public func deleteBibleReadingGarden(
    for entry: BibleReadingGardenLogEntry,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    gardenLogRepository.didLogReadingOnDay(entry) { [weak self] result in
      guard let self else {
        completion(.failure(CommonError.referenceDeallocated))
        return
      }
      
      switch result {
      case .success(let didLog):
        if didLog {
          /// 존재할 때만 삭제할 수 있는거임
          tracker.decreaseForTodayReadingChapters()
          gardenLogRepository.delete(entry, completion: completion)
        } else {
//          값을 제거할 때 없는 데이터라면, 에러 방출 x하도록"
//          assertionFailure("\(BibleReadingGardenError.hasAlreadyInvalidEntry) 값을 제거할 때 없는 데이터라면, 에러 방출 x하도록")
//          completion(.failure(BibleReadingGardenError.hasAlreadyInvalidEntry))
          completion(.success(()))
        }
      case .failure(let failure):
        completion(.failure(failure))
      }
    }
  }
}
