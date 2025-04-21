//
//  JourneyOfFaithGateway.swift
//  JourneyOfFaithApp
//
//  Created by 양승현 on 4/2/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import Swinject

public struct JourneyOfFaithGateway {
  public func makeJourneyOfFaithModule(resolver: Resolver) -> UITabBarController {
    let coordinator = MainTapCoordinator(resolver: resolver)
    return coordinator.makeTabBarController()
  }
}
