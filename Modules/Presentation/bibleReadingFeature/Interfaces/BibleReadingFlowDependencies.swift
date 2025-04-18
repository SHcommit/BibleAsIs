//
//  BibleReadingFlowDependencies.swift
//  BibleReadingFeature
//
//  Created by 양승현 on 3/25/25.
//

import UIKit
import Swinject
import DomainEntity
import DesignSystemItems

public protocol BibleReadingFlowDependencies {  
  func makeViewController(
    currentReadingEntryItem startPageEntryItem: BibleReadingEntryItem,
    readingEntryItemsForRange: [BibleReadingEntryItem]
  ) -> UIViewController
  
  func showBibleNotePageForWriting(
    bibleVerse: BibleVerse,
    range: NSRange,
    /// 저장했다면 not nil 저장안하면( 작성안하면 nil )
    noteAddCompletion: ((BibleNote?) -> Void)?)
  
  func showBibleNotePageForReading(
    bibleVerse: BibleVerse,
    noteId: Int?,
    range: NSRange,
    noteDeleted: ((Bool) -> Void)?)
  
  func showSettingViewController(
    updatedFontSizeHandler: ((CGFloat) -> Void)?,
    ownerPickSleepTimeOptionHandler: ((SleepTimerOption) -> Void)?)
  
  func makeBibleReadingPage(
  currentReadingEntryItem: BibleReadingEntryItem,
  bibleReadingEntryItemsForRange: [BibleReadingEntryItem],
  entryBySleepAudioPlay: Bool,
  delegate: BibleReadingViewControllerDelegate?
  ) -> UIViewController
}
