//
//  DefaultUserSystemSettingAppearanceUseCase.swift
//  Domain
//
//  Created by 양승현 on 3/12/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import DomainInterface

public final class DefaultUserSystemSettingAppearanceUseCase: UserSystemSettingAppearanceUpdateUseCase {
  // MARK: - Dependencies
  private let userSystemSettingRepository: UserSystemSettingsRepository
  
  // MARK: - Lifecycle
  public init(userSystemSettingRepository: UserSystemSettingsRepository) {
    self.userSystemSettingRepository = userSystemSettingRepository
  }
  
  // MARK: - Helpers
  public func updateFontSize(_ fontSize: CGFloat) {
    var prevSettings = userSystemSettingRepository.loadUserSystemSettings()
    if prevSettings.fontSize == fontSize { return }
    prevSettings.fontSize = fontSize
    userSystemSettingRepository.saveUserSystemSettings(prevSettings)
  }
  
  public func updateAppearance(_ appearance: DomainEntity.DisplayAppearance) {
    var prevSettings = userSystemSettingRepository.loadUserSystemSettings()
    if prevSettings.appearance == appearance { return }
    prevSettings.appearance = appearance
    userSystemSettingRepository.saveUserSystemSettings(prevSettings)
  }
  
  public func fetchAppearance() -> DomainEntity.DisplayAppearance {
    let curSettings = userSystemSettingRepository.loadUserSystemSettings()
    return curSettings.appearance
  }
}
