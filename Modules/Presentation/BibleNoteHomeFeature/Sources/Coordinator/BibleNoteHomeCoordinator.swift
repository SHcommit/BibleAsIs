//
//  BibleNoteHomeCoordinator.swift
//  BibleNoteHomeFeature
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import Common
import Swinject
import DomainEntity
import DesignSystem
import DesignSystemItems
import BibleNoteInterface
import BibleNoteHomeInterface

struct BibleNoteHomeCoordinator: BibleNoteHomeFlowDependencies, FlowCoordinatable {
  weak var navigationController: UINavigationController?
  
  var resolver: Swinject.Resolver
  
  init(navigationController: UINavigationController? = nil, resolver: Swinject.Resolver) {
    self.navigationController = navigationController
    self.resolver = resolver
  }
  
  func makeViewController(
    forPageViewMode: Bool,
    entryWithNote: DomainEntity.BibleNote?,
    andVerseForNote: DomainEntity.BibleVerse?) -> UIViewController {
    guard let viewController = resolver.resolve(
      UIViewController.self,
      name: BibleNoteHomeViewController._identifier,
      arguments: self, forPageViewMode, entryWithNote, andVerseForNote
    ) else { fatalError(.registrationErrorMsgByInner(BibleNoteHomeViewController.self)) }
    return viewController
  }

  func showNotePage(
    bibleNote: DomainEntity.BibleNote?,
    noteId: Int?,
    range: NSRange,
    bibleVerse: DomainEntity.BibleVerse,
    delegator: BibleNoteCoordinatorDelegate
  ) {
    guard let bibleNoteGateway = resolver.resolve(BibleNoteInterface.self) else {
      fatalError(.registrationErrorMsgByUnknownOuter(type: BibleNoteInterface.self))
    }
    let bibleNoteViewController = bibleNoteGateway.makeNoteModule(
      navigationController: navigationController,
      resolver: resolver,
      coordinatorDelegate: delegator,
      bibleNote: bibleNote,
      noteId: noteId,
      noteRange: range,
      bibleVerse: bibleVerse)
    
    navigationController?.pushViewController(bibleNoteViewController, animated: true)
  }
}
