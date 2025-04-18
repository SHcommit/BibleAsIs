//
//  BibleHomeCoordinatorDependencies.swift
//  BibleHomeFeatureInterface
//
//  Created by 양승현 on 3/24/25.
//

import UIKit
import Swinject

public protocol BibleHomeInterface {
  func makeBibleHomeModule(
    navigationController: UINavigationController?,
    resolver: Swinject.Resolver
  ) -> UIViewController
}
