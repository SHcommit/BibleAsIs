//
//  BibleHighlight.swift
//  Domain
//
//  Created by 양승현 on 1/30/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public struct BibleHighlight: PrettyDebugStringConvertible {
  public let id: Int
  public let verseId: Int
  public let range: NSRange
  public let colorIndex: Int
  public let date: Date
  
  public init(id: Int, verseId: Int, range: NSRange, colorIndex: Int, date: Date) {
    self.id = id
    self.verseId = verseId
    self.range = range
    self.colorIndex = colorIndex
    self.date = date
  }
}
