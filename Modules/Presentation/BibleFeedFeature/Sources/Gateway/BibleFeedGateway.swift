//
//  BibleFeedGateway.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 3/28/25.
//

import UIKit
import Swinject
import BibleFeedInterface

public struct BibleFeedGateway: BibleFeedInterface {
  public func makeBibleFeedModule(
    navigationController: UINavigationController?,
    resolver: any Swinject.Resolver
  ) -> UIViewController {
    let feedCoordinator = BibleFeedCoordinator(navigationController: navigationController, resolver: resolver)
    return feedCoordinator.makeViewController()
  }
}
