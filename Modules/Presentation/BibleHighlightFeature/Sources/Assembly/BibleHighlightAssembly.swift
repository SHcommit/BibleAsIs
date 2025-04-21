//
//  BibleHighlightAssembly.swift
//  BibleHighlightFeature
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import Common
import Swinject
import ReactorKit
import DomainInterface
import BibleHighlightInterface

public struct BibleHighlightAssembly: Swinject.Assembly {
  public init() { }
  
  public func assemble(container: Container) {
    container.register(
      (any Reactor).self,
      name: BibleHighlightHistoryReactor._identifier) { r in
        guard let highlightFetchUseCase = r.resolve(BibleHighlightFetchUseCase.self) else {
          fatalError(errMsgByOuter(type: BibleHighlightFetchUseCase.self))
        }
        guard let verseFetchUseCase = r.resolve(BibleVerseFetchUseCase.self) else {
          fatalError(errMsgByOuter(type: BibleVerseFetchUseCase.self))
        }
        
        return BibleHighlightHistoryReactor(
          highlightFetchUseCase: highlightFetchUseCase,
          verseFetchUseCase: verseFetchUseCase)
      }
    
    container.register(
      UIViewController.self,
      name: BibleHighlightHistoryViewController._identifier
    ) { (r, coordinator: BibleHighlightCoordinator, forPageViewMode: Bool) in
      guard
        let highlightHistoryReactor = r.resolve(
          (any Reactor).self,
          name: BibleHighlightHistoryReactor._identifier) as? BibleHighlightHistoryReactor
      else { fatalError(errMsgByInner(BibleHighlightHistoryReactor.self)) }
      
      let highlightHistoryViewController = BibleHighlightHistoryViewController(forPageView: forPageViewMode, flowDependencies: coordinator)
      highlightHistoryViewController.reactor = highlightHistoryReactor
      return highlightHistoryViewController
    }
    
    container.register(BibleHighlightInterface.self) { _ in
      return BibleHighlightGateway()
    }
  }
}
