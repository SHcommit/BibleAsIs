//
//  SceneDelegate.swift
//  JourneyOfFaithApp
//
//  Created by 양승현 on 1/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import Swinject
import DesignSystem
import BibleHomeFeature

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  private(set) var appDIContainer: AppDIContainer!
  
  var window: UIWindow?
  
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    appDIContainer = AppDIContainer()
    Typography.register()
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    
    let baseNavigationControlelr = UINavigationController()
    
//    let gateway = appDIContainer.resolver.resolve(BibleHomeInterface.self)
//    let viewController = gateway!.makeBibleHomeModule(
//      navigationController: baseNavigationControlelr,
//      resolver: appDIContainer.resolver)
    let viewController = BibleHomeGateway().makeBibleHomeModule(
      navigationController: baseNavigationControlelr,
      resolver: appDIContainer.resolver)
    
    baseNavigationControlelr.viewControllers = [viewController]
    window?.rootViewController = baseNavigationControlelr
    window?.makeKeyAndVisible()
  }
}
