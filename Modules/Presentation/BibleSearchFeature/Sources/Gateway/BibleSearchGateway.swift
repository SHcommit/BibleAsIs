//
//  BibleSearchGateway.swift
//  BibleSearchFeature
//
//  Created by 양승현 on 3/25/25.
//

import UIKit
import Swinject
import BibleSearchInterface

public struct BibleSearchGateway: BibleSearchInterface {
  public init() { }
  
  public func makeSearchModule(
    navigationController: UINavigationController?,
    resolver: (any Swinject.Resolver)
  ) -> UIViewController {
    let searchCoordinator = BibleSearchCoordinator(navigationController: navigationController, resolver: resolver)
    return searchCoordinator.makeViewController()
  }
}
