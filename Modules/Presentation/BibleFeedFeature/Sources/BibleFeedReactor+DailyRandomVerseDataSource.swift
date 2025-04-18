//
//  BibleFeedReactor+DailyRandomVerseDataSource.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 3/19/25.
//

import RxSwift
import ReactorKit
import Foundation
import DomainEntity
import DesignSystemItems

// MARK: - 인터페이스 분리
import DesignSystem

extension BibleFeedReactor: BibleFeedAdapterDailyRandomVerseDataSource {
  public func dailyRandomVerseItems() -> [DesignSystemItems.BibleRandomVerseItem] {
    return convertToBibleRandomVerseItems(currentState.bibleRandomVerses)
  }
  
  public func dailyRandomVerseHeaderItem() -> String {
    "오늘의 말씀 묵상"
  }
  
  func convertToBibleRandomVerseItems(_ bibleVerses: [[BibleVerse]]) -> [BibleRandomVerseItem] {
    return bibleVerses.compactMap { verses in
      guard let firstVerse = verses.first else {
        assertionFailure("분명히 값이 있어야하지만 없음.")
        return nil
      }
      let book = firstVerse.book.name
      let chapter = firstVerse.chapter
      
      let startVerse = firstVerse.verse
      let endVerse = verses.last?.verse ?? startVerse
      let verseRange = startVerse == endVerse ? "\(startVerse)" : "\(startVerse)-\(endVerse)"
      
      let bibleReferenceText = "\(book) \(chapter):\(verseRange)"
      
      let bibleVerseContents = verses.map { $0.content }.joined(separator: " ")
      
      return BibleRandomVerseItem(
        verseContetns: bibleVerseContents,
        bibleReferenceText: bibleReferenceText,
        bibleStartReference: firstVerse.toBibleReference()
      )
    }
  }
}
