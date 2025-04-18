//
//  BibleDailyReadingEntry.swift
//  Domain
//
//  Created by 양승현 on 2/3/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public struct BibleDailyReadingEntry: Equatable, PrettyDebugStringConvertible {
  public let year: Int
  public let month: Int
  public let day: Int
  public var numberOfReadingChapters: Int
  
  public var id: String {
    "\(year).\(month).\(day)"
  }
  
  public init(year: Int, month: Int, day: Int, numberOfReadingChapters: Int) {
    self.year = year
    self.month = month
    self.day = day
    self.numberOfReadingChapters = numberOfReadingChapters
  }
}
