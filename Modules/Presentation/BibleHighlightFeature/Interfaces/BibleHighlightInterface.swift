//
//  BibleHighlightInterface.swift
//  BibleHighlightInterface
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import Swinject

public protocol BibleHighlightInterface {
  func makeBibleHighlightModule(
    navigationController: UINavigationController?,
    resolver: Resolver,
    forPageViewMode: Bool
  ) -> UIViewController
}
