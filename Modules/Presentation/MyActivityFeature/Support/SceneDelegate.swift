//
//  SceneDelegate.swift
//  JourneyOfFaithApp
//
//  Created by 양승현 on 1/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import Swinject
import MyActivityInterface

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  private var appDIContainer: AppDIContainer = .init()
  var window: UIWindow?
  
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    
    let naviController = UINavigationController()
    let myActivityGateway = appDIContainer.resolver.resolve(MyActivityInterface.self)!
    let myActivityViewController = myActivityGateway.makeMyActivityModule(
      navigationController: naviController,
      resolver: appDIContainer.resolver)
    naviController.viewControllers = [myActivityViewController]
    
    window?.rootViewController = naviController
      
//    window?.rootViewController = BaseNavigationController(rootViewController: MyActivityViewController(), shouldhideNavigationBarInRootVC: true)
    window?.makeKeyAndVisible()
  }
}
