//
//  SceneDelegate.swift
//  BibleHighlightFeatureDemoApp
//
//  Created by 양승현 on 1/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import Swinject
import BibleHighlightFeature

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
//    let gateway = appDIContainer.resolver.resolve(BibleHighlightInterface.self)!
//    let vc = gateway.makeBibleHighlightModule(navigationController: navi, resolver: appDIContainer.resolver)
    let vc = BibleHighlightGateway().makeBibleHighlightModule(
      navigationController: navi,
      resolver: appDIContainer.resolver,
      forPageViewMode: false)
    navi.viewControllers = [vc]
    
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = vc
    window?.makeKeyAndVisible()
  }
}
