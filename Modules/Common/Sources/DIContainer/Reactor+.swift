//
//  Reactor+.swift
//  Common
//
//  Created by 양승현 on 4/7/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

#if canImport(ReactorKit)
import ReactorKit

extension Reactor {
  public static var _identifier: String {
    .init(describing: Self.self)
  }
}
#endif
