//
//  SettingGateway.swift
//  JourneyOfFaithSettingFeatureDemoApp
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import Swinject
import SettingInterface

public final class SettingGateway: SettingInterface {
  public func makeSettingModule(
    navigationController: UINavigationController?,
    resolver: any Swinject.Resolver,
    delegate: SettingCoordinatorDelegate?
  ) -> UIViewController {
    let settingCoordinator = SettingCoordinator(
      navigationController: navigationController,
      resolver: resolver,
      delegate: delegate)
    return settingCoordinator.makeViewController()
  }
}
