//
//  DefaultUserSystemSettingFontUseCase.swift
//  DomainEntity
//
//  Created by 양승현 on 3/12/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import DomainInterface

public final class DefaultUserSystemSettingFontUseCase: UserSystemSettingFontUseCase {
  // MARK: - Dependencies
  private let userSystemSettingRepository: UserSystemSettingsRepository
  
  // MARK: - Lifecycle
  public init(userSystemSettingRepository: UserSystemSettingsRepository) {
    self.userSystemSettingRepository = userSystemSettingRepository
  }
  
  // MARK: - Helpers
  public func updateFontSize(_ fontSize: CGFloat) {
    var prevSettings = userSystemSettingRepository.loadUserSystemSettings()
    prevSettings.fontSize = fontSize
    userSystemSettingRepository.saveUserSystemSettings(prevSettings)
  }
  
  public func fetchFontSize() -> CGFloat {
    let curSettings = userSystemSettingRepository.loadUserSystemSettings()
    return curSettings.fontSize
  }
}
