//
//  BibleHomeFeatureAssembly.swift
//  BibleHomeFeature
//
//  Created by 양승현 on 3/24/25.
//

import UIKit
import Swinject
import ReactorKit
import DomainInterface
import BibleHomeInterface

public struct BibleHomeFeatureAssembly: Assembly {
  public init() { }
  public func assemble(container: Container) {
    container.register((any Reactor).self, name: String(describing: BibleHomeReactor.self)) { r in
      guard let recentBibleBookclipRepository = r.resolve(RecentBibleBookclipRepository.self) else {
        fatalError("RecentBibleBookclipRepository 등록 안했거나 assemblier assembly 잘못함")
      }
      return BibleHomeReactor(recentBibleBookclipRepository: recentBibleBookclipRepository)
    }
    
    container.register(
      UIViewController.self,
      name: BibleHomeViewController._identifier
    ) { (r, flowDependencies: BibleHomeCoordinator) in
      guard
        let bibleHomeReactor = r.resolve(
          (any Reactor).self,
          name: String(describing: BibleHomeReactor.self)
        ) as? BibleHomeReactor else {
        fatalError("bible home reactor 등록 안됨")
      }
      let homeViewController = BibleHomeViewController(flowDependencies: flowDependencies)
      homeViewController.reactor = bibleHomeReactor
      return homeViewController
    }
    
    container.register(BibleHomeInterface.self) { _ in
      return BibleHomeGateway()
    }
  }
}
