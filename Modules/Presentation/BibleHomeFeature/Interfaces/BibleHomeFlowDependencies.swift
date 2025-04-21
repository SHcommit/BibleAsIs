//
//  BibleHomeFlowDependencies.swift
//  BibleHomeInterface
//
//  Created by 양승현 on 3/25/25.
//

import Foundation
import DomainEntity

public protocol BibleHomeFlowDependencies {
  func showSearchPage()
  func showBibleReadingPage(testament: BibleTestament, book: BibleBook, chapter: Int)
}
