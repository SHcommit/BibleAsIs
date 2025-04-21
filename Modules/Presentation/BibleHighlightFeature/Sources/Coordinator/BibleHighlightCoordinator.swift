//
//  BibleHighlightCoordinator.swift
//  BibleHighlightFeature
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import Common
import Swinject
import DomainEntity
import DesignSystemItems
import BibleReadingInterface
import BibleHighlightInterface

struct BibleHighlightCoordinator: BibleHighlightFlowDependencies, FlowCoordinatable {
  weak var navigationController: UINavigationController?
  
  var resolver: Swinject.Resolver
  
  init(navigationController: UINavigationController? = nil, resolver: Swinject.Resolver) {
    self.navigationController = navigationController
    self.resolver = resolver
  }
  
  func makeViewController(forPageViewMode: Bool) -> UIViewController {
    guard let viewController = resolver.resolve(
      UIViewController.self,
      name: BibleHighlightHistoryViewController._identifier,
      arguments: self,
      forPageViewMode
    ) else {
      fatalError(.registrationErrorMsgByInner(BibleHighlightHistoryViewController.self))
    }
    return viewController
  }
  
  func showBibleReadingPage(testament: BibleTestament, book: BibleBook, chapter: Int) {
    let currentBibleReadingEntryItem = BibleReadingEntryItem(bibleBook: book, chapter: chapter)
    guard let bibleReadingGateway = resolver.resolve(bibleReadingInterface.self) else {
      fatalError("BibleReadingInterface 등록 안됨")
    }
    let bibleContentPaginationViewController = bibleReadingGateway.makeBibleContentPaginationModule(
      navigationController: navigationController,
      resolver: resolver,
      currentReadingEntryItem: currentBibleReadingEntryItem,
      bibleReadingEntryItemsForRange: [],
      isRestrictEntry: false)
    
    bibleContentPaginationViewController.hidesBottomBarWhenPushed = true
    
    navigationController?.pushViewController(bibleContentPaginationViewController, animated: true)

  }
}
