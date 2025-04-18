//
//  SceneDelegate.swift
//  JourneyOfFaithApp
//
//  Created by 양승현 on 1/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import Swinject

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  // MARK: - Properties
  private(set) var appDIContainer = AppDIContainer()
  
  var window: UIWindow?
  
  // MARK: - Helpers
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    let launchVC = LaunchScreenViewController.init(nibName: nil, bundle: nil)
    window?.rootViewController = launchVC
    window?.makeKeyAndVisible()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: { [weak self] in
      guard let self else { return }
      
      if hasCompletedOnboarding {
        showBibleAsIsPage()
      } else {
        let onboardingViewController = OnboardingViewController()
        onboardingViewController.shouldShowBibleFeedPage = { [weak self] in
          guard let self else { return }
          updateOnboardingCompletion()
          showBibleAsIsPage()
        }
        window?.rootViewController = onboardingViewController
      }
    })
    
//    window?.makeKeyAndVisible()
    updateAppearance()
    
    // requestNotificationPermission()
  }
  
  private func showBibleAsIsPage() {
    let journeyOfFaithGateway = JourneyOfFaithGateway()
    let viewController = journeyOfFaithGateway.makeJourneyOfFaithModule(resolver: appDIContainer.resolver)
    window?.rootViewController = viewController
  }
}
