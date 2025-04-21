//
//  BibleFeedInterface.swift
//  BibleFeedInterface
//
//  Created by 양승현 on 3/28/25.
//

import UIKit
import Swinject

public protocol BibleFeedInterface {
  func makeBibleFeedModule(
    navigationController: UINavigationController?,
    resolver: Resolver
  ) -> UIViewController
}
