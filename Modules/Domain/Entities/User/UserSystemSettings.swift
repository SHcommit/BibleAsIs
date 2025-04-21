//
//  UserSystemSettings.swift
//  DomainEntity
//
//  Created by 양승현 on 3/12/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public struct UserSystemSettings: Codable, PrettyDebugStringConvertible {
  public var fontSize: CGFloat
  public var appearance: DisplayAppearance
  
  public init(fontSize: CGFloat, appearance: DisplayAppearance) {
    self.fontSize = fontSize
    self.appearance = appearance
  }
}
