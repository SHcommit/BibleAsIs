//
//  SceneDelegate.swift
//  JourneyOfFaithApp
//
//  Created by 양승현 on 1/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import Swinject
import BibleReadingChecklistFeature

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  private(set) var appDIContainer = AppDIContainer()
  
  var window: UIWindow?
  
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    let navi = UINavigationController()
//    let gateway = appDIContainer.resolver.resolve(BibleReadingChecklistInterface.self)!
//    let vc = gateway.makeBibleReadingChecklistModule(navigationController: navi, resolver: appDIContainer.resolver, dismissCompletionHandler: nil)
    
    let vc = BibleReadingChekclistGateway().makeBibleReadingChecklistModule(
      navigationController: navi,
      resolver: appDIContainer.resolver,
      dismissCompletionHandler: nil)
    navi.viewControllers = [vc]
    
    /// 여기서 네비바도 rc + 1 증가시켜버려야함
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = navi
    window?.makeKeyAndVisible()
  }
}
