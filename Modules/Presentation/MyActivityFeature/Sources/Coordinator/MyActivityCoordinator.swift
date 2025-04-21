//
//  MyActivityCoordinator.swift
//  MyActivityFeature
//
//  Created by 양승현 on 3/27/25.
//

import UIKit
import Common
import Swinject
import MyActivityInterface
import BibleNoteHomeInterface
import BibleHighlightInterface
import BibleHeartHistoryInterface
import BibleReadingChecklistInterface
import BibleMccCheyneChallengeInterface

struct MyActivityCoordinator: FlowCoordinatable, MyActivityCoordinatorFlowDependencies {
  weak var navigationController: UINavigationController?
  
  var resolver: Swinject.Resolver
  
  init(
    navigationController: UINavigationController? = nil,
    resolver: Swinject.Resolver
  ) {
    self.navigationController = navigationController
    self.resolver = resolver
  }
  
  func makeViewController() -> UIViewController {
    guard let activityVC = resolver.resolve(
      UIViewController.self,
      name: MyActivityViewController._identifier,
      argument: self
    ) else { fatalError(.registrationErrorMsgByInner(MyActivityViewController.self)) }
    return activityVC
  }
  
  func makeBibleHighlightHistoryViewController() -> UIViewController {
    guard let bibleHighlightHistoryGateway = resolver.resolve(BibleHighlightInterface.self) else {
      fatalError(.registrationErrorMsgByUnknownOuter(type: BibleHighlightInterface.self))
    }
    return bibleHighlightHistoryGateway.makeBibleHighlightModule(
      navigationController: navigationController,
      resolver: resolver, forPageViewMode: true)
  }
  
  func makeBibleMccCheyneChallengeViewController() -> UIViewController {
    guard let bibleMccCheyneChallengeGateway = resolver.resolve(BibleMccCheyneChallengeInterface.self) else {
      fatalError(.registrationErrorMsgByUnknownOuter(type: BibleMccCheyneChallengeInterface.self))
    }
    let mccCheyneViewController = bibleMccCheyneChallengeGateway.makeSettingModule(
      navigationController: navigationController,
      resolver: resolver)
    
    return mccCheyneViewController
  }
  
  func showBibleReadingChecklistViewController(
    dismissCompletionHandler: (() -> Void)?,
    transitioningDelegator: UIViewControllerTransitioningDelegate
  ) {
    guard let checklistGateway = resolver.resolve(
      BibleReadingChecklistInterface.self
    ) else { fatalError(.registrationErrorMsgByUnknownOuter(type: BibleReadingChecklistInterface.self)) }
    let bibleChecklistViewContrller = checklistGateway.makeBibleReadingChecklistModule(
      navigationController: navigationController,
      resolver: resolver,
      dismissCompletionHandler: dismissCompletionHandler)
    
    bibleChecklistViewContrller.transitioningDelegate = transitioningDelegator
    bibleChecklistViewContrller.modalPresentationStyle = .custom
    
    /// 아쉽다.
    /// 기존에는 present전환을 시점으로 Hero Animatior을 만들었는데
    /// 이제 모듈들 합치니까.. bible checklist 화면을 present로보여주면 거기안에서 또 화면 못보여줌..
    navigationController?.pushViewController(bibleChecklistViewContrller, animated: true)
    
    // 이슈가 present가 되네!. -> 또 그위에 prsent 못함
//    navigationController?.present(bibleChecklistViewContrller, animated: true)
  }
  
  func makeBibleNoteHomeViewController() -> UIViewController {
    let noteHomeGateway = resolver.resolve(BibleNoteHomeInterface.self)
    guard let viewController = noteHomeGateway?.makeBibleNoteHomeModule(
      navigationController: navigationController,
      resolver: resolver,
      forPageViewMode: true,
      entryWithNote: nil,
      andVerseForNote: nil
    ) else { fatalError(.registrationErrorMsgByUnknownOuter(type: BibleNoteHomeInterface.self)) }
    
    return viewController
  }
  
  func makeHeartHistoryViewController() -> UIViewController {
    guard let heartHistoryGateway = resolver.resolve(BibleHeartHistoryInterface.self) else {
      fatalError(.registrationErrorMsgByUnknownOuter(type: BibleHeartHistoryInterface.self))
    }
    
    let heartHistoryViewController = heartHistoryGateway.makeBibleHeartHistoryModule(
      navigationController: navigationController,
      resolver: resolver,
      forPageViewMode: true)
    
    return heartHistoryViewController
  }
  
  func makeBibleReadingPlanHomeViewController() -> UIViewController {
    guard let bibleReadingPlanHomeViewController = resolver.resolve(
      UIViewController.self,
      name: BibleReadingPlanHomeViewController._identifier,
      argument: self
    ) else { fatalError(.registrationErrorMsgByInner(BibleReadingPlanHomeViewController.self)) }
    return bibleReadingPlanHomeViewController
  }
}
