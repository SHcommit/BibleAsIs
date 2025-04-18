//
//  DisplayAppearance.swift
//  DomainEntity
//
//  Created by 양승현 on 3/12/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

// @available(iOS 12.0, *)
// public enum UIUserInterfaceStyle : Int, @unchecked Sendable {
//
//  case unspecified = 0
//  
//  case light = 1
//  
//  case dark = 2
// }
@available(iOS 12.0, *)
public enum DisplayAppearance: Int, Codable {
  case `default` = 0
  case light = 1
  case dark = 2
}
