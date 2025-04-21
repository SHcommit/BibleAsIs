//
//  BibleSearchCoordinator.swift
//  BibleSearchFeature
//
//  Created by 양승현 on 3/25/25.
//

import UIKit
import Swinject
import DomainEntity
import DesignSystemItems
import BibleSearchInterface
import BibleReadingInterface

struct BibleSearchCoordinator: BibleSearchFlowDependencies {
  private weak var navigationController: UINavigationController?
  
  private var resolver: Swinject.Resolver
  
  init(
    navigationController: UINavigationController?,
    resolver: Swinject.Resolver
  ) {
    self.navigationController = navigationController
    self.resolver = resolver
  }
  
  public func makeViewController() -> UIViewController {
    guard let bibleSearchViewController = resolver.resolve(
      UIViewController.self,
      name: BibleSearchViewController._identifier,
      argument: self
    ) else {
      fatalError("BibleSearchViewController 등록 안 됨. 확인바람")
    }
    return bibleSearchViewController
  }
  
  func makeSearchResultViweController() -> UIViewController {
    guard let searchResultViewController = resolver.resolve(
      UIViewController.self,
      name: BibleSearchResultViewController._identifier,
      argument: self
    ) else {
      fatalError("BibleSearchResultViewController 등록 안 됨. 확인 바람")
    }
    
    return searchResultViewController
  }
  
  func showBibleReadingPage(testament: BibleTestament, book: DomainEntity.BibleBook, chapter: Int) {
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
