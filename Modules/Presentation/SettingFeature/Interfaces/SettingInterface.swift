//
//  SettingInterface.swift
//  SettingInterface
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import Swinject

public protocol SettingInterface {
  func makeSettingModule(
    navigationController: UINavigationController?,
    resolver: Swinject.Resolver,
    delegate: SettingCoordinatorDelegate?
  ) -> UIViewController
}
