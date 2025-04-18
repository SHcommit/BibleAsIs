//
//  Weekday.swift
//  Entity
//
//  Created by 양승현 on 2/4/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public enum Weekday: Int, CaseIterable, Equatable {
  case sunday = 0, monday, tuesday, wednesday, thursday, friday, saturday
  
  public var day: Int { rawValue }
  
  public var symbol: String {
    switch self {
    case .sunday: return "일"
    case .monday: return "월"
    case .tuesday: return "화"
    case .wednesday: return "수"
    case .thursday: return "목"
    case .friday: return "금"
    case .saturday: return "토"
    }
  }
  
  public static func from(index: Int) -> Self? {
    return Self(rawValue: index)
  }
}
