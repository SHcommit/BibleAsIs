//
//  BibleHighlightGateway.swift
//  BibleHighlightFeature
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import Swinject
import BibleHighlightInterface

public struct BibleHighlightGateway: BibleHighlightInterface {
  public func makeBibleHighlightModule(
    navigationController: UINavigationController?,
    resolver: Resolver,
    forPageViewMode: Bool
  ) -> UIViewController {
    let coordinator = BibleHighlightCoordinator(navigationController: navigationController, resolver: resolver)
    return coordinator.makeViewController(forPageViewMode: forPageViewMode)
  }
}
