//
//  UserSystemSettingsRepository.swift
//  DomainEntity
//
//  Created by 양승현 on 3/12/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol UserSystemSettingsRepository {
  func saveUserSystemSettings(_ systemSettings: UserSystemSettings)
  func loadUserSystemSettings() -> UserSystemSettings
}
