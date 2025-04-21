//
//  SceneDelegate.swift
//  JourneyOfFaithApp
//
//  Created by 양승현 on 1/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import BibleMccCheyneChallengeFeature

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var appDIC: AppDIContainer!
  var window: UIWindow?
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    appDIC = AppDIContainer()
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    let navigationController = UINavigationController()
//    let mccCheyneChallengeGateway = appDIC.resolver.resolve(BibleMccCheyneChallengeInterface.self)
//    guard let viewController = mccCheyneChallengeGateway?.makeSettingModule(
//      navigationController: navigationController,
//      resolver: appDIC.resolver) else { fatalError("의존성 등록 안됨 확인바람") }
    let viewController = BibleMccCheyneChallengeGateway().makeSettingModule(
      navigationController: navigationController,
      resolver: appDIC.resolver)
    navigationController.viewControllers = [viewController]
    
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
  }
}
