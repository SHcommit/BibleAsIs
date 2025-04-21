//
//  BibleReadingPlanFlowDependencies.swift
//  BibleMccCheyneChallengeInterface
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import DomainEntity
import DesignSystemItems

public protocol BibleReadingPlanFlowDependencies {
  func makeViewController() -> UIViewController
  
  func showMccCheyneDescription()
  
  func showRestrictedRangeBasedBibleReadingPage(references: [BibleMccCheyneReference])
}
