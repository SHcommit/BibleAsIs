//
//  BibleNoteHomeFlowDependencies.swift
//  BibleNoteHomeInterface
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import DomainEntity
import BibleNoteInterface

public protocol BibleNoteHomeFlowDependencies {
  /// 노트 화면으로 진입해야하는 경우는 3가지다.
  ///
  /// 1. forPageViewMode yes or not?
  /// 3. forpageViewModel == false 일 때 note, verse를 통해서 홈 -> 바로 노트 화면으로 보여져야 할 경우
  func makeViewController(
    forPageViewMode: Bool,
    entryWithNote: BibleNote?,
    andVerseForNote: BibleVerse?
  ) -> UIViewController
  
  
  func showNotePage(
    bibleNote: BibleNote?,
    noteId: Int?,
    range: NSRange,
    bibleVerse: BibleVerse,
    delegator: BibleNoteCoordinatorDelegate)
}
