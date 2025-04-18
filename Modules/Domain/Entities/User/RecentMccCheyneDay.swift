//
//  RecentMccCheyneDay.swift
//  DomainInterface
//
//  Created by 양승현 on 2/26/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public struct RecentMccCheyneDay: Codable {
  public var currentDay: Int
  
  public init(currentDay: Int) {
    self.currentDay = currentDay
  }
}
