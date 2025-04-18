//
//  Identifiable.swift
//  Common
//
//  Created by 양승현 on 3/25/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public protocol Identifiable { }
extension Identifiable {
  public static var _identifier: String {
    String(describing: Self.self)
  }
}
