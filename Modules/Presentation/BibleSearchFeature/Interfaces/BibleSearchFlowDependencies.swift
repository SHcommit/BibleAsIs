//
//  BibleSearchFlowDependencies.swift
//  BibleSearchFeature
//
//  Created by 양승현 on 3/25/25.
//

import UIKit
import DomainEntity

public protocol BibleSearchFlowDependencies {
  func makeSearchResultViweController() -> UIViewController
  func showBibleReadingPage(testament: BibleTestament, book: BibleBook, chapter: Int)
}
