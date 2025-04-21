//
//  DailyRandomVerseEntity.swift
//  DomainEntity
//
//  Created by 양승현 on 3/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public struct DailyRandomVerseEntity {
  public let day: Int
  public let book: BibleBook
  public let chapter: Int
  public let verse: Int
  
  public init(day: Int, book: BibleBook, chapter: Int, verse: Int) {
    self.day = day
    self.book = book
    self.chapter = chapter
    self.verse = verse
  }
}
