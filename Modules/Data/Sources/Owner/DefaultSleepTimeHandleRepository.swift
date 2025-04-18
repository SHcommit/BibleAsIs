//
//  DefaultSleepTimeHandleRepository.swift
//  Data
//
//  Created by 양승현 on 3/16/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Common
import Foundation
import DomainEntity
import CoreInterface
import DomainInterface

public final class DefaultSleepTimeHandleRepository: SleepTimeHandleRepository {
  // MARK: - Properties
  private let userStorage: UserStorageProtocol
  
  private let storageKey = UserDefaultsKeys.ownerPickSleepTimer.rawValue
  
  // MARK: - Lifecycle
  public init(userStorage: UserStorageProtocol) {
    self.userStorage = userStorage
  }
  
  // MARK: - Helpers
  public func saveUserPickSleepTime(_ entry: SleepTimeEntry) {
    userStorage.save(entry, forKey: storageKey)
  }
  
  public func fetchUserPickSleepTime() -> SleepTimeEntry? {
    userStorage.load(forKey: storageKey, type: SleepTimeEntry.self)
  }
}
