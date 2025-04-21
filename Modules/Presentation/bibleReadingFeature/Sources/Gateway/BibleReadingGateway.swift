//
//  BibleReadingGateway.swift
//  BibleReadingFeature
//
//  Created by 양승현 on 3/25/25.
//

import UIKit
import Swinject
import DesignSystemItems
import BibleReadingInterface

public struct BibleReadingGateway: bibleReadingInterface {
  public init() { }
  
  public func makeBibleContentPaginationModule(
    navigationController: UINavigationController?,
    resolver: (any Swinject.Resolver),
    currentReadingEntryItem: DesignSystemItems.BibleReadingEntryItem,
    bibleReadingEntryItemsForRange: [DesignSystemItems.BibleReadingEntryItem],
    isRestrictEntry: Bool
  ) -> UIViewController {
    let bibleReadingCoordinator = BibleReadingCoordinator(
      navigationController: navigationController,
      resolver: resolver,
      isRestrictEntry: isRestrictEntry)
    let bibleReadingPageViewController = bibleReadingCoordinator.makeViewController(
      currentReadingEntryItem: currentReadingEntryItem,
      readingEntryItemsForRange: bibleReadingEntryItemsForRange)
    return bibleReadingPageViewController
  }
}
