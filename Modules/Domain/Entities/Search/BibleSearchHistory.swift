//
//  BibleSearchHistory.swift
//  Domain
//
//  Created by 양승현 on 2/23/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public struct BibleSearchHistory: PrettyDebugStringConvertible {
  public let id: Int
  public let date: Date
  public let bibleReference: BibleReference
  public let bibleContent: String
  
  public init(id: Int, date: Date, bibleReference: BibleReference, bibleContent: String) {
    self.id = id
    self.date = date
    self.bibleReference = bibleReference
    self.bibleContent = bibleContent
  }
}
