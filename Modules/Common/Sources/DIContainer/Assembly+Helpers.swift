//
//  Assembly+Helpers.swift
//  Common
//
//  Created by 양승현 on 3/26/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

#if canImport(Swinject)
import Swinject

extension Assembly {
  public func errMsgByOuter<T>(type: T.Type) -> String {
    String.registrationErrorMsgByOuter(type: T.self, inAssembly: Self.self)
  }
  
  public func errMsgByInner<T>(_: T.Type) -> String {
    String.registrationErrorMsgByInner(T.self)
  }
}

#endif
