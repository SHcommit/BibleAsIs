//
//  SettingCoordinatorDelegate.swift
//  SettingInterface
//
//  Created by 양승현 on 3/26/25.
//

import Foundation
import DomainEntity

public protocol SettingCoordinatorDelegate: AnyObject {
  func handleOwnerPickSleepTimerOptionHandler(with option: SleepTimerOption)
  func handleUpdatedFontSize(with fontSize: CGFloat)
}
