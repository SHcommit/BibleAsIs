//
//  BibleReadingPaginationController.swift
//  BibleContentFeature
//
//  Created by 양승현 on 2/17/25.
//

import Foundation
import DesignSystem
import DomainEntity
import DesignSystemItems
import DesignSystemInterface

/// 아쉽게 page curel 모드 이거 비동기처리로 데이터 받아오니까 미리 받아오는게 느려서 화면 다 전환되고 리로드 되서 pageCruel은 취소.
/// 이건 page Cruel은 액티비티 메뉴바에 적용하자 +_+
public final class BibleReadingPaginationController: BiblePaginationDataSource {
  // MARK: - Properties
  public var bibleBook: BibleBook {
    currentPage.bibleBook
  }
  
  public var currentChapter: Int {
    currentPage.chapter
  }
  
  public let bibleReadingEntryItemsForRange: [BibleReadingEntryItem]
  
  public let isRestrictEntry: Bool
  
  /// Case 1. `BibleHomePage` 에 의한 진입일  수 있음
  /// Case 2. `FeedPage`에 의한 진입일 수 있음
  /// Case 3. `MccCheyne`이나 추후 추가될 다양한 미션에 의한 진입일 수 있음
  public var currentPage: BibleReadingEntryItem
  
  // MARK: - Lifecycle
  /// isRestrictEntry == true인 경우, bibleReadingEntryItemsForRange에는 읽어야 할 시작, 끝값을 가져오기 이 때 시작 값을 currentReadingEntryItem 치환 똑같이하기
  /// isRestrictEntry == false인 경우 bibleReadingEntryITemsForRange = [] 보내주기
  /// isRestrictEntry값을 넣은 이유는 그래도 가독성있기 때문임. bibleReadingEntryItemsForRange.isEmpty가 대체 가능하긴한대 의미가 모호해서 그럼.
  ///
  /// 두 개 의 경우가 있음
  /// isRestrictEntry 엄격 모드의 경우에, range를 매번 정해주기때문에 어차피 버튼 활성화 떄매 비교해야해서 버튼 숨기기 때문에 다음 화면으로 못감. 따로 필요 x.
  public init(
    currentReadingEntryItem: BibleReadingEntryItem,
    bibleReadingEntryItemsForRange: [BibleReadingEntryItem],
    isRestrictEntry: Bool
  ) {
    self.currentPage = currentReadingEntryItem
    self.bibleReadingEntryItemsForRange = bibleReadingEntryItemsForRange
    self.isRestrictEntry = isRestrictEntry
  }
  
  // MARK: - Helpers
  public func fetchCurrentPage() -> (bibleBook: BibleBook, chapter: Int) {
    return (bibleBook, currentChapter)
  }
  
  public func fetchNextPage() -> BibleReadingEntryItem {
    if currentChapter + 1 <= bibleBook.numberOfChapters {
      currentPage.chapter += 1
    } else if bibleBook.isOldTestament {
      let oldTestaments = BibleBook.oldTestaments
      let currentBibleIndex: Int? = oldTestaments.firstIndex(of: bibleBook)
      let nextBibleIndex = (currentBibleIndex ?? 0) + 1
      if (0..<oldTestaments.count).contains(nextBibleIndex) {
        currentPage.bibleBook = oldTestaments[nextBibleIndex]
        currentPage.chapter = 1
      } else {
        currentPage.bibleBook = .matthew
        currentPage.chapter = 1
      }
    } else {
      let newTestaments = BibleBook.newTestaments
      let currentBibleIndex: Int? = newTestaments.firstIndex(of: bibleBook)
      let nextBibleIndex = (currentBibleIndex ?? 0) + 1
      if (0..<newTestaments.count).contains(nextBibleIndex) {
        currentPage.bibleBook = newTestaments[nextBibleIndex]
        currentPage.chapter = 1
      } else {
        currentPage.bibleBook = .genesis
        currentPage.chapter = 1
      }
    }
    
    return currentPage
  }
  
  public func fetchPrevPage() -> BibleReadingEntryItem {
    if currentChapter - 1 > 0 {
      currentPage.chapter -= 1
    } else if bibleBook.isOldTestament {
      let oldTestaments = BibleBook.oldTestaments
      let currentBibleIndex: Int? = oldTestaments.firstIndex(of: bibleBook)
      let prevBibleIndex = (currentBibleIndex ?? 0) - 1
      if (0..<oldTestaments.count).contains(prevBibleIndex) {
        currentPage.bibleBook = oldTestaments[prevBibleIndex]
        currentPage.chapter = bibleBook.numberOfChapters - 1
      } else {
        currentPage.bibleBook = .revelation
        currentPage.chapter = bibleBook.numberOfChapters
      }
    } else {
      let newTestaments = BibleBook.newTestaments
      let currentBibleIndex: Int? = newTestaments.firstIndex(of: bibleBook)
      let prevBibleIndex = (currentBibleIndex ?? 0) - 1
      if (0..<newTestaments.count).contains(prevBibleIndex) {
        currentPage.bibleBook = newTestaments[prevBibleIndex]
        currentPage.chapter = bibleBook.numberOfChapters
      } else {
        currentPage.bibleBook = .malachi
        currentPage.chapter = bibleBook.numberOfChapters
      }
    }
    return currentPage
  }
}
