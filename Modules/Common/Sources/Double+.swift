//
//  Double+.swift
//  Common
//
//  Created by 양승현 on 3/3/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

extension Double {
  /// totalValue를 기반으로 현재 값에 대한 퍼센티지를 반환 소수 점 한자리 반올림
  public func calculagePercentage(byTotalValues: Double) -> String {
    guard byTotalValues > 0 else { return "0.0%" }
    let percent = (self/byTotalValues) * 100
    return String(format: "%.1f%%", percent)
  }
}
