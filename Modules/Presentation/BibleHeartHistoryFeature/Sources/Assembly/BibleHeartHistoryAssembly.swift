//
//  BibleHeartHistoryAssembly.swift
//  BibleHeartHistoryFeature
//
//  Created by 양승현 on 3/27/25.
//

import UIKit
import Common
import Swinject
import ReactorKit
import DomainInterface
import BibleHeartHistoryInterface

public struct BibleHeartHistoryAssembly: Assembly {
  public init() { }
  public func assemble(container: Container) {
    container.register(
      (any Reactor).self,
      name: BibleHeartHistoryReactor._identifier) { r in
        guard let bibleHeartFetchUseCase = r.resolve(BibleHeartFetchUseCase.self) else {
          fatalError(errMsgByOuter(type: BibleHeartFetchUseCase.self))
        }
        guard let bibleHeartDeleteUseCase = r.resolve(BibleHeartDeleteUseCase.self) else {
          fatalError(errMsgByOuter(type: BibleHeartDeleteUseCase.self))
        }
        
        return BibleHeartHistoryReactor(
          bibleHeartFetchUseCase: bibleHeartFetchUseCase,
          bibleHeartDeleteUseCase: bibleHeartDeleteUseCase)
      }
    
    /// 하트 verse 셀 누를 경우 verse화면으로 이동 안하게하려고하는데,, 하트는 그냥 하트한 벌스만 보고 취소할지 유지할지?
    /// 이렇게 하게하려구!
    container.register(
      UIViewController.self,
      name: BibleHeartHistoryViewController._identifier
    ) { (r, forPageViewMode: Bool) in
      guard
        let heartHistoryReactor = r.resolve(
          (any Reactor).self,
          name: BibleHeartHistoryReactor._identifier) as? BibleHeartHistoryReactor
      else { fatalError(errMsgByInner(BibleHeartHistoryReactor.self)) }
      
      let heartHistoryVC = BibleHeartHistoryViewController(forPageViewMode: forPageViewMode)
      heartHistoryVC.reactor = heartHistoryReactor
      return heartHistoryVC
    }
    
    container.register(BibleHeartHistoryInterface.self) { _ in
      BibleHeartHistoryGateway()
    }
  }
}
