//
//  DailyRandomVerseDTO.swift
//  Data
//
//  Created by 양승현 on 3/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import BibleInterface
import DomainEntity

public struct DailyRandomVerseDTO {
  public let day: Int
  public let bookCode: String
  public let chapter: Int
  public let verse: Int
  
  public init(day: Int, bookCode: String, chapter: Int, verse: Int) {
    self.day = day
    self.bookCode = bookCode
    self.chapter = chapter
    self.verse = verse
  }
  
  public init(from entry: DailyRandomVerseEntry) {
    self.bookCode = entry.bookCode
    self.day = entry.day
    self.chapter = entry.chapter
    self.verse = entry.verse
  }
}

// MARK: - Mappings DTO
extension DailyRandomVerseDTO {
  func toDomain() -> DailyRandomVerseEntity {
    let book = BibleBook(code: bookCode)
    if book == nil {
      assertionFailure("북코드 이상한거 들어감 확인해야 함")
    }
    return .init(day: day, book: book ?? .genesis, chapter: chapter, verse: verse)
  }
}
