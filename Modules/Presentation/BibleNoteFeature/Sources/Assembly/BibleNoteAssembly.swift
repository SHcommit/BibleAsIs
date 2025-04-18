//
//  BibleNoteAssembly.swift
//  BibleNoteFeature
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import Common
import Swinject
import ReactorKit
import DomainEntity
import CoreInterface
import DomainInterface
import BibleNoteInterface

public struct BibleNoteAssembly: Swinject.Assembly {
  public init() { }
  
  public func assemble(container: Swinject.Container) {
    container.register(
      (any Reactor).self,
      name: BibleNoteReactor._identifier
    ) { (r, bibleNote: BibleNote?, noteId: Int?, range: NSRange, bibleVerse: BibleVerse) in
      guard let noteUseCase = r.resolve(BibleNoteUseCase.self) else {
        fatalError(errMsgByOuter(type: BibleNoteUseCase.self))
      }
      
      guard let textHasher = r.resolve(TextHashable.self) else {
        fatalError(errMsgByOuter(type: TextHashable.self))
      }
      
      return BibleNoteReactor(
        initialState: .init(bibleNote: bibleNote, noteId: noteId, range: range, bibleVerse: bibleVerse),
        noteUseCase: noteUseCase, textHasher: textHasher)
    }
    
    container.register(
      UIViewController.self,
      name: BibleNoteViewController._identifier
    ) { (r, coordinator: BibleNoteCoordinator, bibleNote: BibleNote?, noteId: Int?, range: NSRange, bibleVerse: BibleVerse) in
      guard let textHasher = r.resolve(TextHashable.self) else {
        fatalError(errMsgByOuter(type: TextHashable.self))
      }
      
      guard let bibleNoteReactor = r.resolve(
        (any Reactor).self,
        name: BibleNoteReactor._identifier,
        arguments: bibleNote, noteId, range, bibleVerse
      ) as? BibleNoteReactor else { fatalError(errMsgByInner(BibleNoteReactor.self)) }
      
      let bibleNoteViewController = BibleNoteViewController(delegate: coordinator, textHasher: textHasher)
      bibleNoteViewController.reactor = bibleNoteReactor
      return bibleNoteViewController
    }
    
    container.register(BibleNoteInterface.self) { _ in
      return BibleNoteGateway()
    }
  }
}
