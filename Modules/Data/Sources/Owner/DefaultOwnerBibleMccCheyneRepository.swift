//
//  DefaultOwnerBibleMccCheyneRepository.swift
//  Data
//
//  Created by 양승현 on 2/26/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Common
import Foundation
import DomainEntity
import CoreInterface
import DomainInterface

public final class DefaultOwnerBibleMccCheyneRepository: OwnerBibleMccCheyneRepository {
  internal typealias Keys = UserDefaultsKeys
  
  // MARK: - Properties
  private let storage: UserStorageProtocol
  
  private let backgroundQueue = DispatchQueue(
    label: "com.bible.bibleRepository.queue",
    qos: .userInteractive)
  
  // MARK: - Lifecycle
  public init(storage: UserStorageProtocol) {
    self.storage = storage
  }
  
  // MARK: - Helpers
  public func fetchCurrentChallengeDay(completion: @escaping (Result<RecentMccCheyneDay, any Error>) -> Void) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      guard let recent = storage.load(forKey: Keys.mccCheyneCurrentDay.forKey, type: RecentMccCheyneDay.self) else {
        let mccCheyne = RecentMccCheyneDay(currentDay: 1)
        storage.save(mccCheyne, forKey: Keys.mccCheyneCurrentDay.forKey)
        completion(.success(mccCheyne))
        return
      }
      completion(.success(recent))
    }
  }
  
  public func updateCurrentChallengeDay(
    _ day: Int,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      guard var recent = storage.load(forKey: Keys.mccCheyneCurrentDay.forKey, type: RecentMccCheyneDay.self) else {
        let mccCheyne = RecentMccCheyneDay(currentDay: day)
        storage.save(mccCheyne, forKey: Keys.mccCheyneCurrentDay.forKey)
        completion(.success(()))
        return
      }
      recent.currentDay = day
      storage.save(recent, forKey: Keys.mccCheyneCurrentDay.forKey)
      completion(.success(()))
    }
  }
}
