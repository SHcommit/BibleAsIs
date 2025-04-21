//
//  SleepTimerOption.swift
//  Domain
//
//  Created by 양승현 on 2/8/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public enum SleepTimerOption: String, CaseIterable {
  // forTests
//  case o = "30초"
  case fiveMinutes = "5분"
  case tenMinutes = "10분"
  case thirtyMinutes = "30분"
  case fourtyFiveMinutes = "45분"
  case oneHour = "1시간"
  case twoHour = "2시간"
  case threeHour = "3시간"
  
  public var toTimeInterval: TimeInterval {
    switch self {
//    case .o: return .init(30)
    case .fiveMinutes: return .init(300)
    case .tenMinutes: return .init(600)
    case .thirtyMinutes: return .init(1800)
    case .fourtyFiveMinutes: return .init(2700)
    case .oneHour: return .init(3600)
    case .twoHour: return .init(7200)
    case .threeHour: return .init(10800)
    }
  }
  
  public static var numberOfOptions: Int {
    Self.allCases.count
  }
  
  public static func option(by index: Int) -> Self {
    allCases[index]
  }
}
