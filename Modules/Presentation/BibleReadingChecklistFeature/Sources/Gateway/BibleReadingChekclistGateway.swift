//
//  BibleReadingChekclistGateway.swift
//  BibleReadingChecklistFeature
//
//  Created by 양승현 on 3/27/25.
//

import UIKit
import Swinject
import BibleReadingChecklistInterface

public struct BibleReadingChekclistGateway: BibleReadingChecklistInterface {
  public func makeBibleReadingChecklistModule(
    navigationController: UINavigationController?,
    resolver: any Swinject.Resolver,
    dismissCompletionHandler: (() -> Void)?
  ) -> UIViewController {
    let coordinator = BibleReadingChecklistCoordinator(
      navigationController: navigationController,
      resolver: resolver)
    
    return coordinator.makeViewController(dismissCompletionHandler: dismissCompletionHandler)
  }
}
