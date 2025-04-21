//
//  WeekdayRange.swift
//  Entity
//
//  Created by 양승현 on 2/4/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public struct WeekdayRange: Equatable, PrettyDebugStringConvertible {
  /// Month에서 시작 요일
  public let start: Weekday
  /// Month에서 마지막 요일
  public let end: Weekday
  
  public init(start: Weekday, end: Weekday) {
    self.start = start
    self.end = end
  }
}
