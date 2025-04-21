//
//  BibleHeartHistoryCoordinator.swift
//  BibleHeartHistoryFeature
//
//  Created by 양승현 on 3/27/25.
//

import UIKit
import Common
import Swinject

public protocol BibleHeartHistoryFlowDependencies {
  func makeViewController(forPageViewMode: Bool) -> UIViewController
}

public struct BibleHeartHistoryCoordinator: FlowCoordinatable, BibleHeartHistoryFlowDependencies {
  public var navigationController: UINavigationController?
  
  public var resolver: any Swinject.Resolver
  
  init(navigationController: UINavigationController? = nil, resolver: any Swinject.Resolver) {
    self.navigationController = navigationController
    self.resolver = resolver
  }
  
  public func makeViewController(forPageViewMode: Bool) -> UIViewController {
    guard let heartHistoryViewController = resolver.resolve(
      UIViewController.self,
      name: BibleHeartHistoryViewController._identifier,
      argument: forPageViewMode
    ) else { fatalError(.registrationErrorMsgByInner(BibleHeartHistoryViewController.self)) }
    return heartHistoryViewController
  }
}
