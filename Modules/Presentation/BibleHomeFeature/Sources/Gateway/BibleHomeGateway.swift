//
//  BibleHomeGateway.swift
//  BibleHomeFeature
//
//  Created by 양승현 on 3/25/25.
//

import UIKit
import Swinject
import BibleHomeInterface

public struct BibleHomeGateway: BibleHomeInterface {
  public init() { }

  public func makeBibleHomeModule(
    navigationController: UINavigationController?,
    resolver: Swinject.Resolver
  ) -> UIViewController {
    let bibleHomeCoordinator = BibleHomeCoordinator(navigationController: navigationController, resolver: resolver)
    return bibleHomeCoordinator.makeViewController()
  }
}
