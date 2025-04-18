//
//  SettingViewControllerDelegate.swift
//  SettingInterface
//
//  Created by 양승현 on 3/26/25.
//

import Foundation

public protocol SettingViewControllerDelegate: AnyObject {
  func showTimerSettingPage()
  func handleUpdatedFontSize(_ fontSize: CGFloat)
}
