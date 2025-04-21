//
//  BibleNoteFlowDependencies.swift
//  bibleNoteInterface
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import DomainEntity

public protocol BibleNoteFlowDependencies {
  func makeViewController(
    bibleNote: BibleNote?,
    noteId: Int?,
    range: NSRange,
    bibleVerse: BibleVerse
  ) -> UIViewController
}
