//
//  BibleHighlightFlowDependencies.swift
//  BibleHighlightInterface
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import DomainEntity

public protocol BibleHighlightFlowDependencies {
  func makeViewController(forPageViewMode: Bool) -> UIViewController
  
  func showBibleReadingPage(testament: BibleTestament, book: BibleBook, chapter: Int)
}
