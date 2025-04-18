//
//  SceneDelegate.swift
//  JourneyOfFaithApp
//
//  Created by 양승현 on 1/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import DesignSystem

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    Typography.register()
    guard let windowScene = (scene as? UIWindowScene) else { return }
//    let viewController = DailyChallengeViewController()
    // let viewController = SleepTimerViewController()
    let viewController = TV2()
    
    // let viewController = BibleViewController()
    // let viewController = ViewController()
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = UINavigationController(rootViewController: viewController)
    window?.makeKeyAndVisible()
  }
  // 다른 생명주기 메서드들도 필요에 따라 추가할 수 있습니다.
}
