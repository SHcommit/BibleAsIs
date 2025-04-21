//
//  MyActivityGateway.swift
//  JourneyOfFaithMyActivityFeatureDemoApp
//
//  Created by 양승현 on 3/27/25.
//

import UIKit
import Swinject
import MyActivityInterface

public struct MyActivityGateway: MyActivityInterface {
  public init() { }
  
  public func makeMyActivityModule(
    navigationController: UINavigationController?,
    resolver: any Resolver
  ) -> UIViewController {
    let activityCoordinator = MyActivityCoordinator(navigationController: navigationController, resolver: resolver)
    return activityCoordinator.makeViewController()
  }
}
