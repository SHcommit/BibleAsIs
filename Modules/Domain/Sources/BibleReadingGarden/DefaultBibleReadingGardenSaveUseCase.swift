//
//  DefaultBibleReadingGardenSaveUseCase.swift
//  Domain
//
//  Created by 양승현 on 3/14/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import DomainInterface

public final class DefaultBibleReadingGardenSaveUseCase: BibleReadingGardenSaveUseCase {
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
  /// sql특징
  /// tracker의 경우 update활용(이미 저장된 레코드에 값을 지속적으로 증가 or 감소 해야함
  /// Log의 경우 매번 거의 새로운 값 넣음 몇 쪽 읽었는지 파악해야함 insert or replace (혹시 중복 방지)
  ///
  /// 여기서 보통 디비에 동시로 접근하는 문제 생겼는데 지금은 괜찮음.
  public func saveBibleReadingGarden(
    for newEntry: BibleReadingGardenLogEntry,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    gardenLogRepository.didLogReadingOnDay(newEntry) { [weak self] result in
      guard let self else {
        completion(.failure(CommonError.referenceDeallocated))
        return
      }
      
      switch result {
      case .success(let didLog):
        if didLog {
          /// 이미 로그 남긴 경우 그냥 오케 그렇게 하자!
          completion(.success(()))
        } else {
          tracker.increaseForTodayReadingChapters()
          gardenLogRepository.saveBibleReadingGardenForDay(newEntry, completion: completion)
        }
      case .failure(let failure):
        completion(.failure(failure))
      }
    }
  }
}
