//
//  BibleHeartHistoryGateway.swift
//  BibleHeartHistoryFeature
//
//  Created by 양승현 on 3/27/25.
//

import UIKit
import Swinject
import BibleHeartHistoryInterface

struct BibleHeartHistoryGateway: BibleHeartHistoryInterface {
  func makeBibleHeartHistoryModule(
    navigationController: UINavigationController?,
    resolver: any Swinject.Resolver,
    forPageViewMode: Bool
  ) -> UIViewController {
    let heartHistoryCoordinator = BibleHeartHistoryCoordinator(
      navigationController: navigationController,
      resolver: resolver)
    return heartHistoryCoordinator.makeViewController(forPageViewMode: forPageViewMode)
  }
}
