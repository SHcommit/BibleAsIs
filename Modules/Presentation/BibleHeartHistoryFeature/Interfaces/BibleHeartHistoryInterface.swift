//
//  BibleHeartHistoryInterface.swift
//  BibleHeartHistoryInterface
//
//  Created by 양승현 on 3/27/25.
//

import UIKit
import Swinject

public protocol BibleHeartHistoryInterface {
  func makeBibleHeartHistoryModule(
    navigationController: UINavigationController?,
    resolver: Resolver,
    forPageViewMode: Bool
  ) -> UIViewController
}
