//
//  BibleReadingGardenLogEntry.swift
//  DomainEntity
//
//  Created by 양승현 on 3/14/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public struct BibleReadingGardenLogEntry {
  public let year: Int
  public let month: Int
  public let day: Int
  public let book: BibleBook
  public let chapter: Int
  
  public init(year: Int, month: Int, day: Int, book: BibleBook, chapter: Int) {
    self.year = year
    self.month = month
    self.day = day
    self.book = book
    self.chapter = chapter
  }
}
