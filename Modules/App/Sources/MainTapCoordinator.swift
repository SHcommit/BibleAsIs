//
//  MainTapCoordinator.swift
//  JourneyOfFaithApp
//
//  Created by 양승현 on 4/1/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import Common
import Swinject
import DesignSystem

import BibleHomeInterface
import BibleFeedInterface
import MyActivityInterface

public protocol MainTapFlowDependencies {
  func makeTabBarController() -> UITabBarController
  
  func makeHomeViewController(with tabBarItem: UITabBarItem) -> BaseNavigationController
  
  func makeBibleHomeViewController(with tabBarItem: UITabBarItem) -> BaseNavigationController
  
  func makeMyActivityViewController(with tabBarItem: UITabBarItem) -> BaseNavigationController
}

public struct MainTapCoordinator: MainTapFlowDependencies {
  
  private var resolver: Swinject.Resolver
  
  init(resolver: any Swinject.Resolver) {
    self.resolver = resolver
  }
  
  public func makeTabBarController() -> UITabBarController {
    MainTabBarController(flowDependencies: self)
  }
  
  public func makeHomeViewController(with tabBarItem: UITabBarItem) -> BaseNavigationController {
    let baseNavigationController = BaseNavigationController(shouldHideNavigationShadowInRootVC: true)
    guard let feedGateway = resolver.resolve(BibleFeedInterface.self) else {
      fatalError(.registrationErrorMsgByInner(BibleFeedInterface.self))
    }
    let feedModule = feedGateway.makeBibleFeedModule(
      navigationController: baseNavigationController,
      resolver: resolver)
    feedModule.tabBarItem = tabBarItem
    baseNavigationController.viewControllers = [feedModule]
    
    return baseNavigationController
  }
  
  public func makeBibleHomeViewController(with tabBarItem: UITabBarItem) -> BaseNavigationController {
    let baseNavigationController = BaseNavigationController(shouldhideNavigationBarInRootVC: false)
    let gateway = resolver.resolve(BibleHomeInterface.self)
    let bibleHomeModule = gateway!.makeBibleHomeModule(
      navigationController: baseNavigationController,
      resolver: resolver)
  
    bibleHomeModule.tabBarItem = tabBarItem
    baseNavigationController.viewControllers = [bibleHomeModule]
    return baseNavigationController

  }
  
  public func makeMyActivityViewController(with tabBarItem: UITabBarItem) -> BaseNavigationController {
    let baseNavigationController = BaseNavigationController()
    
    let myActivityGateway = resolver.resolve(MyActivityInterface.self)!
    let myActivityModule = myActivityGateway.makeMyActivityModule(
      navigationController: baseNavigationController,
      resolver: resolver)
    myActivityModule.tabBarItem = tabBarItem
    baseNavigationController.viewControllers = [myActivityModule]
    return baseNavigationController
  }
}
