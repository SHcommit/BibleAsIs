//
//  BibleSearchInterface.swift
//  BibleSearchFeatureInterface
//
//  Created by 양승현 on 3/25/25.
//

import UIKit
import Swinject

public protocol BibleSearchInterface {
  func makeSearchModule(
    navigationController: UINavigationController?,
    resolver: Swinject.Resolver
  ) -> UIViewController
}
