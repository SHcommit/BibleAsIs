//
//  BibleNoteHomeGateway.swift
//  BibleNoteHomeFeature
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import Swinject
import DomainEntity
import BibleNoteHomeInterface

public struct BibleNoteHomeGateway: BibleNoteHomeInterface {
  public func makeBibleNoteHomeModule(
    navigationController: UINavigationController?,
    resolver: Resolver,
    forPageViewMode: Bool,
    entryWithNote: BibleNote?,
    andVerseForNote: BibleVerse?
  ) -> UIViewController {
    let coordinator = BibleNoteHomeCoordinator(navigationController: navigationController, resolver: resolver)
    return coordinator.makeViewController(
      forPageViewMode: forPageViewMode,
      entryWithNote: entryWithNote,
      andVerseForNote: andVerseForNote)
  }
}
