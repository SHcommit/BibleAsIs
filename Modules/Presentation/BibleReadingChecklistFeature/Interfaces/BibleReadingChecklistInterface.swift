//
//  BibleReadingChecklistInterface.swift
//  BibleHighlightInterface
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import Swinject

public protocol BibleReadingChecklistInterface {
  func makeBibleReadingChecklistModule(
    navigationController: UINavigationController?,
    resolver: Resolver,
    dismissCompletionHandler: (() -> Void)?
  ) -> UIViewController
}
