//
//  SettingCoordinator.swift
//  JourneyOfFaithSettingFeatureDemoApp
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import Common
import Swinject
import DomainEntity
import SettingInterface

public final class SettingCoordinator: SettingFlowDependencies {
  private weak var navigationController: UINavigationController?
  
  private var resolver: Swinject.Resolver
  
  private weak var delegate: SettingCoordinatorDelegate?
  
  init(
    navigationController: UINavigationController? = nil,
    resolver: Swinject.Resolver,
    delegate: SettingCoordinatorDelegate?
  ) {
    self.delegate = delegate
    self.navigationController = navigationController
    self.resolver = resolver
  }
  
  public func makeViewController() -> UIViewController {
    guard
      let settingViewController = resolver.resolve(
        UIViewController.self,
        name: SettingViewController._identifier,
        argument: self)
    else { fatalError(String.registrationErrorMsgByInner(SettingViewController.self)) }
    return settingViewController
  }
}

// MARK: - SettingViewControllerDelegate
extension SettingCoordinator: SettingViewControllerDelegate {
  public func showTimerSettingPage() {
    navigationController?.dismiss(animated: true) { [weak self] in
      guard let self else { return }
      let audioSettingViewController = AudioSettingViewController(sleepTimerDuration: nil, flowDependencies: self)
      audioSettingViewController.ownerPickSleepTimerOptionHandler = { [weak self] ownerPickSleepTimeOption in
        guard let self else { return }
        delegate?.handleOwnerPickSleepTimerOptionHandler(with: ownerPickSleepTimeOption)
      }
      navigationController?.present(audioSettingViewController, animated: true)
    }
  }
  
  public func handleUpdatedFontSize(_ fontSize: CGFloat) {
    delegate?.handleUpdatedFontSize(with: fontSize)
  }
}
