//
//  SceneDelegate.swift
//  JourneyOfFaithApp
//
//  Created by 양승현 on 1/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import Common
import Swinject
import BibleFeedFeature

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  private(set) var appDIContainer: AppDIContainer = .init()
  
  var window: UIWindow?
  
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    let naviController = UINavigationController()
//    guard let feedGateway = appDIContainer.resolver.resolve(BibleFeedInterface.self) else {
//      fatalError(.registrationErrorMsgByInner(BibleFeedInterface.self))
//    }
//    let feedViewController = feedGateway.makeBibleFeedModule(
//      navigationController: naviController,
//      resolver: appDIContainer.resolver)
    let feedViewController = BibleFeedGateway().makeBibleFeedModule(
      navigationController: naviController,
      resolver: appDIContainer.resolver)
    naviController.viewControllers = [feedViewController]

    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = naviController
    window?.makeKeyAndVisible()
  }
}
