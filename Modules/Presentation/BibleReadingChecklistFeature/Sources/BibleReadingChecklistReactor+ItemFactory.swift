//
//  BibleReadingChecklistReactor+ItemFactory.swift
//  BibleReadingChecklistFeature
//
//  Created by 양승현 on 3/23/25.
//

import Foundation
import DomainEntity
import DesignSystemItems

// MARK: - Item Factory
extension BibleReadingChecklistReactor {
  /// 이건 초기에!
  func makeChapterItems(
    book: BibleBook,
    readChapterEntries: [DailyBibleReadingChapterEntry]
  ) -> CheckableBibleDailyReadingItem {
    var chapterItems = (1...book.numberOfChapters).map { index in
      let reference = TestamentOfBookChapterItem(chapterNumber: index, isClipped: false)
      return CheckableTestamentOfBookChaperItem(
        reference: reference,
        alreadyRead: false,
        dateString: nil)
    }
    
    for readChapterEntry in readChapterEntries {
      chapterItems[readChapterEntry.chapter-1].alreadyRead = true
      if let readChapterDate = readChapterEntry.date {
        chapterItems[readChapterEntry.chapter-1].dateString = dateController.convertYYMMDDString(from: readChapterDate)
      }
    }
    
    return CheckableBibleDailyReadingItem(
      book: book,
      chapters: "\(book.numberOfChapters) chapters",
      isExpended: false,
      chapterItems: chapterItems,
      currentValue: readChapterEntries.count,
      totalValue: book.numberOfChapters)
  }
}
