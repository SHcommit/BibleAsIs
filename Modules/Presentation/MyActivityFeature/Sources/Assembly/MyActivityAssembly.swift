//
//  MyActivityAssembly.swift
//  JourneyOfFaithMyActivityFeatureDemoApp
//
//  Created by 양승현 on 3/27/25.
//

import UIKit
import Common
import Swinject
import ReactorKit
import DomainInterface
import MyActivityInterface

public struct MyActivityAssembly: Swinject.Assembly {
  public init() { }
  
  public func assemble(container: Container) {
    // MARK: - ReadingPlanHome
    container.register((any Reactor).self, name: BibleReadingPlanHomeReactor._identifier) { r in
      guard let dailyReadingUseCase = r.resolve(DailyBibleReadingChecklistUseCase.self) else {
        fatalError(errMsgByOuter(type: DailyBibleReadingChecklistUseCase.self))
      }
      return BibleReadingPlanHomeReactor(dailyReadingUseCase: dailyReadingUseCase)
    }
    
    container.register(
      UIViewController.self,
      name: BibleReadingPlanHomeViewController._identifier
    ) { (r, flowDependencies: MyActivityCoordinator) in
      guard let dailyReadingPlanHomeReactor = r.resolve(
        (any Reactor).self,
        name: BibleReadingPlanHomeReactor._identifier
      ) as? BibleReadingPlanHomeReactor else { fatalError(errMsgByInner(BibleReadingPlanHomeReactor.self)) }
      
      let bibleReadingPlanHomeViewController = BibleReadingPlanHomeViewController(flowDependencies: flowDependencies)
      bibleReadingPlanHomeViewController.reactor = dailyReadingPlanHomeReactor
      return bibleReadingPlanHomeViewController
    }
    
    // MARK: - MyActivity
    container.register(UIViewController.self, name: MyActivityViewController._identifier) { (_, coordinator: MyActivityCoordinator) in
      return MyActivityViewController(flowDependencies: coordinator)
    }
    
    container.register(MyActivityInterface.self) { _ in
      return MyActivityGateway()
    }
  }
}
