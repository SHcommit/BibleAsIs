//
//  BibleGardenLevel.swift
//  Domain
//
//  Created by 양승현 on 2/3/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public enum BibleGardenLevel: Int {
  /// 여기서 히든은 지난달 요일임! 한달은 5~6주로 구성되기에, 토요일이 첫주의 시작이면, 이전요일들은 히든처리 가즈아~
  case hidden = -1
  case none = 0
  case low = 1
  case medium = 3
  case high = 6
  case veryHigh = 10
  case extreme = 15

  public static let levelAllCases: [Self] = [.none, .low, .medium, .high, .veryHigh, .extreme]
  
  public static func level(for value: Int) -> Self {
    switch value {
    case -1:
      return .hidden
    case 0:
      return .none
    case 1..<3:
      return .low
    case 3..<6:
      return .medium
    case 6..<10:
      return .high
    case 10..<15:
      return .veryHigh
    default:
      return .extreme
    }
  }
}
