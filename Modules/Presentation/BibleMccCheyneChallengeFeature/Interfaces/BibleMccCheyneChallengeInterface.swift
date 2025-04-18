//
//  BibleMccCheyneChallengeInterface.swift
//  BibleMccCheyneChallengeInterface
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import Swinject

public protocol BibleMccCheyneChallengeInterface {
  
  func makeSettingModule(
    navigationController: UINavigationController?,
    resolver: any Swinject.Resolver
  ) -> UIViewController
}

public struct BibleMccCheyneChallengeConstraints {
  public static var mccCheyneChallengeHeight: CGFloat { 460 }
}

public protocol BibleMccCheyneRefreshable {
  func reloadData()
}
