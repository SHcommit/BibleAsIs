//
//  BibleNoteGateway.swift
//  BibleNoteFeature
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import Swinject
import DomainEntity
import BibleNoteInterface

public struct BibleNoteGateway: BibleNoteInterface {
  public init() { }
  
  public func makeNoteModule(
    navigationController: UINavigationController?,
    resolver: any Swinject.Resolver,
    coordinatorDelegate: BibleNoteCoordinatorDelegate,
    bibleNote: BibleNote?,
    noteId: Int?,
    noteRange: NSRange,
    bibleVerse: BibleVerse
  ) -> UIViewController {
    let noteCoordinator = BibleNoteCoordinator(
      navigationController: navigationController,
      resolver: resolver,
      delegate: coordinatorDelegate)
    return noteCoordinator.makeViewController(
      bibleNote: bibleNote,
      noteId: noteId,
      range: noteRange,
      bibleVerse: bibleVerse)
  }
}
