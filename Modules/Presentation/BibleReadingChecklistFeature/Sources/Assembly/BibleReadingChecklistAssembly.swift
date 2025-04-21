//
//  BibleReadingChecklistAssembly.swift
//  BibleReadingChecklistFeature
//
//  Created by 양승현 on 3/27/25.
//

import UIKit
import Common
import Swinject
import ReactorKit
import CoreInterface
import DomainInterface
import BibleReadingChecklistInterface

/// 이게 여러 화면에서 쓰일 수 있음. 동기화가 필요함.
/// 싱글톤 말고 weak하게 가자.
public struct BibleReadingChecklistAssembly: Swinject.Assembly {
  public init() { }
  
  // swiftlint:disable closure_parameter_position
  public func assemble(container: Container) {
    container.register((any Reactor).self, name: BibleReadingChecklistReactor._identifier) { r in
      guard let bibleReadingPlanUseCase = r.resolve(DailyBibleReadingChecklistUseCase.self) else {
        fatalError(errMsgByOuter(type: DailyBibleReadingChecklistUseCase.self))
      }
      
      guard let bibleReadingGardenSaveUseCase = r.resolve(BibleReadingGardenSaveUseCase.self) else {
        fatalError(errMsgByOuter(type: BibleReadingGardenSaveUseCase.self))
      }
      
      guard let bibleReadingGardenDeleteUseCase = r.resolve(BibleReadingGardenDeleteUseCase.self) else {
        fatalError(errMsgByOuter(type: BibleReadingGardenDeleteUseCase.self))
      }
      
      guard let calendarService = r.resolve(CalendarServiceProtocol.self) else {
        fatalError(errMsgByOuter(type: CalendarServiceProtocol.self))
      }
    
      return BibleReadingChecklistReactor(
        bibleReadingPlanUseCase: bibleReadingPlanUseCase,
        bibleReadingGardenSaveUseCase: bibleReadingGardenSaveUseCase,
        bibleReadingGardenDeleteUseCase: bibleReadingGardenDeleteUseCase,
        calendarService: calendarService)
    }
    
    container.register(
      UIViewController.self,
      name: BibleReadingChecklistViewController._identifier
    ) { (
      r,
      flowDependencies: BibleReadingChecklistCoordinator,
      dismissCompletionHandler: (() -> Void)?) in
      guard let bibleReadingChecklistReactor = r.resolve(
        (any Reactor).self,
        name: BibleReadingChecklistReactor._identifier
      ) as? BibleReadingChecklistReactor else { fatalError(errMsgByInner(BibleReadingChecklistReactor.self)) }
      
      let bibleReadingChecklistViewController = BibleReadingChecklistViewController(
        flowDependencies: flowDependencies,
        dismissCompletionHandler: dismissCompletionHandler)
      bibleReadingChecklistViewController.reactor = bibleReadingChecklistReactor
      return bibleReadingChecklistViewController
    }
    
    container.register(BibleReadingChecklistInterface.self) { _ in
      return BibleReadingChekclistGateway()
    }
  }
  // swiftlint:enable closure_parameter_position
}
