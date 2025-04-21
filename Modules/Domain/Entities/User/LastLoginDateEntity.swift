//
//  LastLoginDateEntity.swift
//  DomainEntity
//
//  Created by 양승현 on 3/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public struct LastLoginDateEntity: Codable {
  public let year: Int
  public let month: Int
  public let day: Int
  
  public init(year: Int, month: Int, day: Int) {
    self.year = year
    self.month = month
    self.day = day
  }
}
