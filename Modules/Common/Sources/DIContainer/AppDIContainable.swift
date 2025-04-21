//
//  AppDIContainable.swift
//  Common
//
//  Created by 양승현 on 3/26/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

#if canImport(Swinject)
import Swinject

public protocol AppDIContainable {
  var assembler: Assembler { get }
  var container: Container { get }
}

extension AppDIContainable {
  public var resolver: Swinject.Resolver {
    assembler.resolver
  }
}

#endif
