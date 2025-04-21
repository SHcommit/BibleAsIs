//
//  BibleNoteCoordinator.swift
//  BibleNoteFeature
//
//  Created by 양승현 on 3/26/25.
//

import Common
import UIKit
import Swinject
import DomainEntity
import BibleNoteInterface

struct BibleNoteCoordinator: BibleNoteFlowDependencies, FlowCoordinatable {
  weak var navigationController: UINavigationController?
  
  var resolver: Swinject.Resolver
  
  var delegate: BibleNoteCoordinatorDelegate
  
  init(
    navigationController: UINavigationController? = nil,
    resolver: Swinject.Resolver,
    delegate: BibleNoteCoordinatorDelegate
  ) {
    self.navigationController = navigationController
    self.resolver = resolver
    self.delegate = delegate
  }
  
  func makeViewController(
    bibleNote: BibleNote?,
    noteId: Int?,
    range: NSRange,
    bibleVerse: BibleVerse
  ) -> UIViewController {
        
    guard let bibleNoteViewController = resolver.resolve(
      UIViewController.self,
      name: BibleNoteViewController._identifier,
      arguments: self,
      bibleNote,
      noteId,
      range,
      bibleVerse
    ) else { fatalError(.registrationErrorMsgByInner(BibleNoteViewController.self)) }
    
    return bibleNoteViewController
  }
}

// MARK: - BibleNoteViewControllerDelegate
extension BibleNoteCoordinator: BibleNoteViewControllerDelegate {
  func handleModifiedNote(modifiedNote: BibleNote?, hasUserModifiedTheNote: Bool, hasUserDeletedTheNote: Bool) {
    print("외부에 보낼 준비가 됬을까요?")
    delegate.handleModifiedNote(
      modifiedNote: modifiedNote,
      hasUserModifiedTheNote: hasUserModifiedTheNote,
      hasUserDeletedTheNote: hasUserDeletedTheNote)
  }
}
