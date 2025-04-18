//
//  DefaultOwnerLastLoginDateRepository.swift
//  Data
//
//  Created by 양승현 on 3/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Common
import Foundation
import DomainEntity
import DomainInterface
import CoreInterface

public final class DefaultOwnerLastLoginDateRepository: OwnerLastLoginDateRepository {
  private let userStorage: UserStorageProtocol
  
  public init(userStorage: UserStorageProtocol) {
    self.userStorage = userStorage
  }
  
  public func saveTodayAsLastLogin(with todayEntity: LastLoginDateEntity) {
    userStorage.save(todayEntity, forKey: UserDefaultsKeys.lastLoginDate.rawValue)
  }
  
  public func fetchLastLoginDate() -> LastLoginDateEntity? {
    return userStorage.load(forKey: UserDefaultsKeys.lastLoginDate.rawValue, type: LastLoginDateEntity.self)
  }
}
