//
//  BibleMccCheyneChallengeGateway.swift
//  BibleMccCheyneChallengeFeature
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import Swinject
import BibleMccCheyneChallengeInterface

public struct BibleMccCheyneChallengeGateway: BibleMccCheyneChallengeInterface {
  public init() { }
  public func makeSettingModule(
    navigationController: UINavigationController?,
    resolver: any Swinject.Resolver
  ) -> UIViewController {
    let mccCheyneCoordinator = BibleMccCheyneChallengeCoordinator(
      navigationController: navigationController,
      resolver: resolver)
    
    return mccCheyneCoordinator.makeViewController()
  }
}
