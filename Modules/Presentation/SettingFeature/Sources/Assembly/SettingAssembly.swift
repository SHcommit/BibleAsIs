//
//  SettingAssembly.swift
//  JourneyOfFaithSettingFeatureDemoApp
//
//  Created by 양승현 on 3/26/25.
//

import UIKit
import Common
import Swinject
import ReactorKit
import DomainInterface
import SettingInterface

public struct SettingAssembly: Swinject.Assembly {
  public init() { }
  
  public func assemble(container: Container) {
    // MARK: - SettingPage
    container.register((any Reactor).self, name: SettingReactor._identifier) { r in
      guard let appearanceUpdateUseCase = r.resolve(UserSystemSettingAppearanceUpdateUseCase.self) else {
        fatalError(errMsgByOuter(type: UserSystemSettingAppearanceUpdateUseCase.self))
      }
      
      guard let fontUpdateUseCase = r.resolve(UserSystemSettingFontUseCase.self) else {
        fatalError(errMsgByOuter(type: UserSystemSettingFontUseCase.self))
      }
      
      return SettingReactor(
        fontUpdateUseCase: fontUpdateUseCase,
        appearanceUpdateUseCase: appearanceUpdateUseCase)
    }
    
    container.register(
      UIViewController.self,
      name: SettingViewController._identifier
    ) { (r, delegate: SettingCoordinator) in
      guard let settingReactor = r.resolve(
        (any Reactor).self,
        name: SettingReactor._identifier
      ) as? SettingReactor else { fatalError(errMsgByInner(SettingReactor.self)) }
      
      let settingViewController = SettingViewController(delegate: delegate)
      settingViewController.reactor = settingReactor
      
      return settingViewController
    }
    
    // MARK: - Gateway
    container.register(SettingInterface.self) { _ in
      return SettingGateway()
    }
    
  }
}
