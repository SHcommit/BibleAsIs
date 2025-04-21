//
//  BibleNoteHomeInterface.swift
//  BibleNoteHomeInterface
//
//  Created by 양승현 on 3/27/25.
//

import UIKit
import Swinject
import DomainEntity

public protocol BibleNoteHomeInterface {
  func makeBibleNoteHomeModule(
    navigationController: UINavigationController?,
    resolver: Resolver,
    forPageViewMode: Bool,
    entryWithNote: BibleNote?,
    andVerseForNote: BibleVerse?
  ) -> UIViewController
}
