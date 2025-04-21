//
//  FlowCoordinatable.swift
//  Common
//
//  Created by 양승현 on 3/26/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

#if canImport(UIKit) && canImport(Swinject)

import UIKit
import Swinject

public protocol FlowCoordinatable {
  var navigationController: UINavigationController? { get }
  var resolver: Swinject.Resolver { get }
}

#endif
