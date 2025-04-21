//
//  BibleNoteInterface.swift
//  bibleNoteInterface
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import Swinject
import DomainEntity

public protocol BibleNoteInterface {
  
  /// makeNoteModule()
  ///
  /// Parameters:
  /// - Parameter bibleNote :
  /// - Parameter noteId : Note가 있다는 것은, 사용자가 노트 화면을 진입할 때 이미 작성한 노트가 있다는 뜻입니다. Note가 없으면 새로 작성하는 사용자입니다.
  func makeNoteModule(
    navigationController: UINavigationController?,
    resolver: any Swinject.Resolver,
    coordinatorDelegate: BibleNoteCoordinatorDelegate,
    bibleNote: BibleNote?,
    noteId: Int?,
    noteRange: NSRange,
    bibleVerse: BibleVerse
  ) -> UIViewController
}
