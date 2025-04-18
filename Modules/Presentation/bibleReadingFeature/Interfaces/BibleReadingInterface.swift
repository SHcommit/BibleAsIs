//
//  BibleReadingInterface.swift
//  BibleReadingInterface
//
//  Created by 양승현 on 3/25/25.
//

import UIKit
import Swinject
import DomainEntity
import DesignSystemItems

// MARK: - 범위 1 개 OK
//    let paginationController = BibleReadingPaginationController(
//      currentReadingEntryItem: startEntry,
//      bibleReadingEntryItemsForRange: [startEntry],
//      isRestrictEntry: true)

// MARK: - 범위 2 개 OK
//    let paginationController = BibleReadingPaginationController(
//      currentReadingEntryItem: startEntry,
//      bibleReadingEntryItemsForRange: [startEntry, endEntry],
//      isRestrictEntry: true)

// MARK: - 범위 5 개 OK
//    endEntry.chapter = 5
//    let paginationController = BibleReadingPaginationController(
//      currentReadingEntryItem: startEntry,
//      bibleReadingEntryItemsForRange: [startEntry, endEntry],
//      isRestrictEntry: true)

// MARK: - free모드 테스트. OK
//    let paginationController = BibleReadingPaginationController(
//      currentReadingEntryItem: startEntry,
//      bibleReadingEntryItemsForRange: [],
//      isRestrictEntry: false)

// MARK: - 오디오 테스트 모드 가장 짧은 chapter. OK
//    let _startEntry = BibleReadingEntryItem(bibleBook: .psalms, chapter: 117)
// let _startEntry = BibleReadingEntryItem(bibleBook: .john, chapter: 3)
public protocol bibleReadingInterface {
  /// isRestrictEntry == true인 경우, bibleReadingEntryItemsForRange에는 읽어야 할 시작, 끝값을 가져오기 이 때 시작 값을 currentReadingEntryItem 치환 똑같이하기
  /// isRestrictEntry == false인 경우 bibleReadingEntryITemsForRange = [] 보내주기 isRestrictEntry값을 넣은 이유는 그래도 가독성있기 때문임.
  /// bibleReadingEntryItemsForRange.isEmpty가 대체 가능하긴한대 의미가 모호해서 그럼.
  func makeBibleContentPaginationModule(
    navigationController: UINavigationController?,
    resolver: Swinject.Resolver,
    currentReadingEntryItem: BibleReadingEntryItem,
    bibleReadingEntryItemsForRange: [BibleReadingEntryItem],
    isRestrictEntry: Bool
  ) -> UIViewController
}
