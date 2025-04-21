//
//  BibleHeart.swift
//  Domain
//
//  Created by 양승현 on 1/30/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public struct BibleHeart: PrettyDebugStringConvertible {
  public let heartId: Int
  public let verseId: Int
  public let heart: Bool
  public var date: Date?
  
  public init(heartId: Int, verseId: Int, heart: Bool, date: Date? = nil) {
    self.heartId = heartId
    self.verseId = verseId
    self.heart = heart
    self.date = date
  }
}
