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
import BibleSearchFeature

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
    
    let navi = UINavigationController()
    
//    let gateway = appDIContainer.resolver.resolve(BibleSearchInterface.self)
//    guard let searchViewController = gateway?.makeSearchModule(
//      navigationController: navi,
//      resolver: appDIContainer.resolver
//    ) else { fatalError("서치 모듈이 Assemlby 되지 않았습니다.") }
    
    let searchViewController = BibleSearchGateway().makeSearchModule(
      navigationController: navi,
      resolver: appDIContainer.resolver)
    
    navi.viewControllers = [searchViewController]
    
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = navi
    window?.makeKeyAndVisible()
  }
}
