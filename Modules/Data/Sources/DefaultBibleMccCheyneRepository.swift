//
//  DefaultBibleMccCheyneRepository.swift
//  Data
//
//  Created by 양승현 on 2/26/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import BibleInterface
import DomainInterface

public final class DefaultBibleMccCheyneRepository: BibleMccCheyneRepository {
  // MARK: - Properties
  private let backgroundQueue = DispatchQueue(
    label: "com.bible.BibleMccCheyneReference.queue",
    qos: .userInteractive)
  
  private let dbManager: BibleMccCheyneDAO
  
  public var numberOfRecords: Int {
    dbManager.numberOfRecords
  }
  
  // MARK: - Lifecycle
  public init(dbManager: BibleMccCheyneDAO) {
    self.dbManager = dbManager
  }
  
  // MARK: - Helpers
  /// day는 1부터 시작
  public func fetchDailyReadingPlan(
    forDay: Int,
    completion: @escaping (Result<DailyMccCheyneEntity?, any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      dbManager.fetchDailyReadingPlan(forDay: forDay) { res in
        completion(.success(res))
      }
    }
  }
  
  /// 컴플리션 값 방출할때 true는 update 성공 false는 업데이트 실패로 보면됨.
  /// day는 1부터 시작
  public func updateDailyReadingPlan(
    forDay: Int,
    entry: DailyMccCheyneEntity,
    completion: @escaping (Result<Bool, any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      dbManager.updateDailyReadingPlan(forDay: forDay, entry: entry) { result in
        completion(.success(result))
      }
    }
  }
}
