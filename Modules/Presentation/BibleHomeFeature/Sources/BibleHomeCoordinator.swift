//
//  BibleHomeCoordinator.swift
//  BibleHomeFeature
//
//  Created by 양승현 on 3/24/25.
//

import UIKit
import Swinject
import DomainEntity
import DesignSystemItems
import BibleHomeInterface
import BibleSearchInterface
import BibleReadingInterface

struct BibleHomeCoordinator: BibleHomeFlowDependencies {
  private weak var navigationController: UINavigationController?
  
  private var resolver: Swinject.Resolver
  
  init(navigationController: UINavigationController? = nil, resolver: Swinject.Resolver) {
    self.navigationController = navigationController
    self.resolver = resolver
  }
  
  public func makeViewController() -> UIViewController {
    guard let bibleHomeViewController = resolver.resolve(
      UIViewController.self,
      name: BibleHomeViewController._identifier,
      argument: self
    ) else {
      fatalError("BibleHomeViewController 등록 안됨 확인바람")
    }
    return bibleHomeViewController
  }
  
  func showSearchPage() {
    guard let searchGateway = resolver.resolve(BibleSearchInterface.self) else {
      fatalError("BibleSearchInterface 등록 안됨. 확인 바람")
    }
    
    let searchViewController = searchGateway.makeSearchModule(
      navigationController: navigationController,
      resolver: resolver)
    
    navigationController?.pushViewController(searchViewController, animated: true)
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
