//
//  SettingViewController+UserInterfaceSettingViewDelegate.swift
//  SettingFeature
//
//  Created by 양승현 on 3/12/25.
//

import RxSwift
import ReactorKit
import Foundation
import DomainEntity
import DesignSystemInterface

// MARK: - UserInterfaceSettingViewDelegate
extension SettingViewController: UserInterfaceSettingViewDelegate {
  public func segmentChanged(for appearance: DisplayAppearance) {
    reactor?.action.onNext(.appearanceUpdate(appearance))
  }
  
  public func didTapTimerPage() {
    delegate?.showTimerSettingPage()
  }
  
  public func updateFontSize(with size: CGFloat) {
    reactor?.action.onNext(.fontSizeUpdate(size))
  }
}
