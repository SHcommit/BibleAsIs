//
//  BibleNoteHomeAssembly.swift
//  BibleNoteHomeFeature
//
//  Created by 양승현 on 3/27/25.
//

import UIKit
import Common
import DomainEntity
import Swinject
import ReactorKit
import DomainInterface
import BibleNoteHomeInterface

public struct BibleNoteHomeAssembly: Swinject.Assembly {
  public init() { }
  
  public func assemble(container: Container) {
    container.register(
      (any Reactor).self,
      name: BibleNoteHomeReactor._identifier
    ) { r in
      guard let bibleNoteUseCase = r.resolve(BibleNoteUseCase.self) else {
        fatalError(errMsgByOuter(type: BibleNoteUseCase.self))
      }
      guard let bibleVerseFetchUseCase = r.resolve(BibleVerseFetchUseCase.self) else {
        fatalError(errMsgByOuter(type: BibleVerseFetchUseCase.self))
      }
      
      return BibleNoteHomeReactor(
        bibleNoteUseCase: bibleNoteUseCase,
        bibleVerseFetchUseCase: bibleVerseFetchUseCase)
    }
    
    container.register(
      UIViewController.self,
      name: BibleNoteHomeViewController._identifier
    ) { (r, coordinator: BibleNoteHomeCoordinator, forPageView: Bool, entryWithNote: BibleNote?, andVerseForNote: BibleVerse?) in
      guard let reactor = r.resolve(
        (any Reactor).self,
        name: BibleNoteHomeReactor._identifier
      ) as? BibleNoteHomeReactor else { fatalError(errMsgByInner(BibleNoteHomeReactor.self)) }

      let bibleNoteHomeViewController = BibleNoteHomeViewController(
        forPageView: forPageView,
        flowDependencies: coordinator,
        entryWithNote: entryWithNote,
        andVerseForNote: andVerseForNote)
      bibleNoteHomeViewController.reactor = reactor
      return bibleNoteHomeViewController
    }
    
    container.register(BibleNoteHomeInterface.self) { _ in
      return BibleNoteHomeGateway()
    }
  }
}
