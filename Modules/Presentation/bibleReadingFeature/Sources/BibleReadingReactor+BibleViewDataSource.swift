//
//  BibleReadingReactor+BibleReadingViewDataSource.swift
//  BibleContentFeature
//
//  Created by 양승현 on 3/17/25.
//

import Foundation
import DomainEntity
import DesignSystemItems
import DesignSystemInterface

extension BibleReadingReactor: BibleReadingViewDataSource {
  public func item(_ indexPath: IndexPath) -> BibleVerseItem {
    currentState.bibleVerses[indexPath.item]
  }
  
  public func fetchBookChapterText() -> String {
    "\(currentReadingEntryItem.bibleBook.name) \(currentReadingEntryItem.chapter)장"
  }
  
  public func fetchPageInfo() -> BibleReadingPageControlItem {
    let currentChapter = currentReadingEntryItem.chapter
    let numberOfChapters = numberOfChapters
    var shouldHidePrev = false
    var shouldHideNext = false
    
    let cur = currentReadingEntryItem
    let forRange = bibleReadingEntryItemsForRange
    if bibleReadingEntryItemsForRange.count >= 3 {
      assertionFailure("Reactor에 데이터를 보내줄 때 Range가 하나면 하나! 범위가 여러개면 그 중 시작, 끝 총 2개 보내주어야함. ")
    }
    
    if isRestrictEntry {
      if bibleReadingEntryItemsForRange.count == 2 {
        if forRange[0] == cur {
          shouldHidePrev = true
        }
        if forRange[1] == cur {
          shouldHideNext = true
        }
      } else {
        shouldHidePrev = true
        shouldHideNext = true
      }
    }
    return BibleReadingPageControlItem(
      currentChapter: currentChapter, numberOfChapters: numberOfChapters,
      shouldHidePrevButton: shouldHidePrev, shouldHideNextButton: shouldHideNext,
      isExecutingAudioMode: currentState.isExecutingAudioMode)
  }
}
