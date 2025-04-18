//
//  BibleMccCheyneChallengeAssembly.swift
//  BibleMccCheyneChallengeFeature
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import Common
import Swinject
import ReactorKit
import CoreInterface
import DomainInterface
import BibleMccCheyneChallengeInterface

public struct BibleMccCheyneChallengeAssembly: Swinject.Assembly {
  public init() { }
  
  public func assemble(container: Container) {
    container.register(
      (any Reactor).self,
      name: BibleMccCheyneChallengeReactor._identifier) { r in
        
        let bibleMccCheyneRepository = r.resolve(BibleMccCheyneRepository.self)!
        let ownerMccCheyneRepository = r.resolve(OwnerBibleMccCheyneRepository.self)!
        let bibleReadingGardenSaveUseCase = r.resolve(BibleReadingGardenSaveUseCase.self)!
        let bibleReadingGardenDeleteUseCase = r.resolve(BibleReadingGardenDeleteUseCase.self)!
        let calendarService = r.resolve(CalendarServiceProtocol.self)!
        
        return BibleMccCheyneChallengeReactor(
          bibleMccCheyneRepository: bibleMccCheyneRepository,
          ownerMccCheyneRepository: ownerMccCheyneRepository,
          bibleReadingGardenSaveUseCase: bibleReadingGardenSaveUseCase,
          bibleReadingGardenDeleteUseCase: bibleReadingGardenDeleteUseCase,
          calendarService: calendarService)
      }
    
    container.register(
      UIViewController.self,
      name: BibleMccCheyneChallengeViewController._identifier
    ) { (r, flowDependencies: BibleMccCheyneChallengeCoordinator) in
      guard let BibleMccCheyneChallengeReactor = r.resolve(
        (any Reactor).self,
        name: BibleMccCheyneChallengeReactor._identifier
      ) as? BibleMccCheyneChallengeReactor else { fatalError(errMsgByInner(BibleMccCheyneChallengeReactor.self)) }
      
      let challengeViewController = BibleMccCheyneChallengeViewController(flowDependencies: flowDependencies)
      challengeViewController.reactor = BibleMccCheyneChallengeReactor
      return challengeViewController
    }
    
    container.register(BibleMccCheyneChallengeInterface.self) { _ in
      BibleMccCheyneChallengeGateway()
    }
  }
}
