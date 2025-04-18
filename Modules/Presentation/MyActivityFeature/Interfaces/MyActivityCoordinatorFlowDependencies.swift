//
//  MyActivityCoordinatorFlowDependencies.swift
//  MyActivityFeature
//
//  Created by 양승현 on 3/27/25.
//

import UIKit

public protocol MyActivityCoordinatorFlowDependencies {
  func makeViewController() -> UIViewController
  
  func makeBibleHighlightHistoryViewController() -> UIViewController
  
  func makeBibleMccCheyneChallengeViewController() -> UIViewController
  
  func makeBibleNoteHomeViewController() -> UIViewController
  
  func makeHeartHistoryViewController() -> UIViewController
  
  func makeBibleReadingPlanHomeViewController() -> UIViewController
  
  func showBibleReadingChecklistViewController(
    dismissCompletionHandler: (() -> Void)?,
    transitioningDelegator: UIViewControllerTransitioningDelegate
  )
}
