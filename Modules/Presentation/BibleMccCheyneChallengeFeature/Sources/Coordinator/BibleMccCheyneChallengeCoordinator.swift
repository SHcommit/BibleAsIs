//
//  BibleMccCheyneChallengeCoordinator.swift
//  BibleReadingChecklistFeature
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import Common
import Swinject
import DomainEntity
import DesignSystemItems
import BibleReadingInterface
import BibleMccCheyneChallengeInterface

struct BibleMccCheyneChallengeCoordinator: FlowCoordinatable, BibleReadingPlanFlowDependencies {
  var navigationController: UINavigationController?
  
  var resolver: any Swinject.Resolver
  
  init(navigationController: UINavigationController? = nil, resolver: any Swinject.Resolver) {
    self.navigationController = navigationController
    self.resolver = resolver
  }
  
  func makeViewController() -> UIViewController {
    guard
      let mccCheyneChallengeViewController = resolver.resolve(
        UIViewController.self,
        name: BibleMccCheyneChallengeViewController._identifier,
        argument: self)
    else { fatalError(.registrationErrorMsgByInner(BibleMccCheyneChallengeViewController.self)) }
    
    return mccCheyneChallengeViewController
  }
  
  func showRestrictedRangeBasedBibleReadingPage(references: [BibleMccCheyneReference]) {
    guard let firstRef = references.first else { return }
    
    let entryItem = BibleReadingEntryItem(bibleBook: firstRef.book, chapter: firstRef.chapter)
    
    guard let bibleReadingGateway = resolver.resolve(bibleReadingInterface.self) else {
      fatalError("BibleReadingInterface 등록 안됨")
    }
    let bibleContentPaginationViewController = bibleReadingGateway.makeBibleContentPaginationModule(
      navigationController: navigationController,
      resolver: resolver,
      currentReadingEntryItem: entryItem,
      bibleReadingEntryItemsForRange: references.map { .init(bibleBook: $0.book, chapter: $0.chapter) },
      isRestrictEntry: true)
    
    bibleContentPaginationViewController.hidesBottomBarWhenPushed = true
    
    navigationController?.pushViewController(bibleContentPaginationViewController, animated: true)
  }

  func showMccCheyneDescription() {
    // MARK: - 맥체인을 왜 읽어야하는가. 어느점이 좋은가 설명 고고링
    // 일단 보류.
//    print("todo: 맥체인 설명 보여주기!")
  }
}
