//
//  BibleItemFactory.swift
//  BibleHomeFeature
//
//  Created by 양승현 on 2/11/25.
//

import Foundation
import DesignSystem
import DomainEntity
import DesignSystemItems

public struct BibleItemFactory {
  /// clippedChapter index는 0부터 시작해야 합니다.
  public static func makeChapterItems(
    book: BibleBook,
    isClipped: Bool,
    clippedChapter: Int?
  ) -> [TestamentOfBookChapterItem] {
    return (1...book.numberOfChapters).map {
      var item = TestamentOfBookChapterItem(chapterNumber: $0, isClipped: false)
      if isClipped, let clippedChapter, $0 == clippedChapter {
        item.isClipped = true
      }
      return item
    }
  }
  
  public static func makeBibleHomeItem(
    testamentType testament: BibleTestament,
    clipInfo clipped: RecentBibleClip
  ) -> [BibleHomeItem] {
    let testaments: [BibleBook] = testament == .old ? BibleBook.oldTestaments : BibleBook.newTestaments
    return testaments.map {
      let chapterItems = Self.makeChapterItems(
        book: $0,
        isClipped: clipped.book == $0,
        clippedChapter: clipped.chapter)
      return BibleHomeItem(
        bookTitle: $0,
        isClipped: $0 == clipped.book,
        isExpended: false,
        chapterItems: chapterItems
      )
    }
  }
}
