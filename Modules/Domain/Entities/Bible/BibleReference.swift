//
//  BibleReference.swift
//  Entity
//
//  Created by 양승현 on 2/18/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public struct BibleReference: Equatable, PrettyDebugStringConvertible {
  public let book: BibleBook
  public let chapter: Int
  public let verse: Int
  
  public init(book: BibleBook, chapter: Int, verse: Int) {
    self.book = book
    self.chapter = chapter
    self.verse = verse
  }
  
  /// verseId
  public var id: Int {
    book.bookOrder * 1_000_000 + chapter * 1_000 + verse
  }
  
  public static func getId(book: BibleBook, chapter: Int, verse: Int) -> Int {
    book.bookOrder * 1_000_000 + chapter*1_000 + verse
  }
  
  public func isEqual(to otherVerse: Self) -> Bool {
    id == otherVerse.id
  }
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
  
  // 내부적으로 bible_fts는 book, chapter, verse를 pk로쓰는데 문자들을 비교할때 느릴거같아서 숫자로 변환해 봤음.
  public init?(bibleReferenceId id: Int) {
    let bookOrder = (id/1_000_000)
    let chapter = (id%1_000_000) / 1_000
    let verse = id % 1_000
    guard let book = BibleBook.bookOrderDictionary.first(where: {$0.value == bookOrder })?.key else {
      return nil
    }
    self = Self.init(book: book, chapter: chapter, verse: verse)
  }
}
