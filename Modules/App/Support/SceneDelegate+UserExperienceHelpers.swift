//
//  SceneDelegate+UserExperienceHelpers.swift
//  JourneyOfFaithApp
//
//  Created by 양승현 on 4/10/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import DomainInterface

// MARK: - UserExperience Helpers
extension SceneDelegate {
  /// 사용자가 지정한 Appearance 를 적용합니다.
  func updateAppearance() {
    guard let appearanceUseCase = appDIContainer.resolver.resolve(UserSystemSettingAppearanceUpdateUseCase.self) else {
      assertionFailure("UseCase Assembly 등록 안됨")
      return
    }
    let displayAppearance = appearanceUseCase.fetchAppearance()
    UIApplication.updateAppearance(displayAppearance)
  }
  
  var hasCompletedOnboarding: Bool {
    UserDefaults.standard.bool(forKey: "isOnboardingCompleted")
  }
  
  func updateOnboardingCompletion() {
    UserDefaults.standard.set(true, forKey: "isOnboardingCompleted")
  }
}
