//
//  DailyBibleReadingChapterEntry.swift
//  Domain
//
//  Created by 양승현 on 3/3/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public struct DailyBibleReadingChapterEntry {
  public let book: BibleBook
  public let chapter: Int
  public var alreadyRead: Bool
  public var date: Date?
  
  public init(book: BibleBook, chapter: Int, alreadyRead: Bool, date: Date? = nil) {
    self.book = book
    self.chapter = chapter
    self.alreadyRead = alreadyRead
    self.date = date
  }
}
