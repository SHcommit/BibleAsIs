//
//  DefaultUserSystemSettingsRepository.swift
//  Data
//
//  Created by 양승현 on 3/12/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Common
import Foundation
import DomainEntity
import CoreInterface
import DomainInterface

// MARK: 메인스레드에서 호출되야 함.
public final class DefaultUserSystemSettingsRepository: UserSystemSettingsRepository {
  typealias Keys = UserDefaultsKeys
 // MARK: - Properties
  private let userStorage: UserStorageProtocol
  
  // MARK: - Lifecycle
  public init(userStorage: UserStorageProtocol) {
    self.userStorage = userStorage
  }
  
  public func saveUserSystemSettings(
    _ systemSettings: UserSystemSettings
  ) {
    userStorage.save(systemSettings, forKey: Keys.userSystemSettings.forKey)
  }
  
  public func loadUserSystemSettings(
  ) -> UserSystemSettings {
    guard let settings = userStorage.load(forKey: Keys.userSystemSettings.forKey, type: UserSystemSettings.self)
    else {
      saveUserSystemSettings(UserSystemSettings(fontSize: 14, appearance: .default))
      return UserSystemSettings(fontSize: 14, appearance: .default)
    }
    return settings
  }
}
