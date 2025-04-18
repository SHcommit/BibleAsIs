//
//  SceneDelegate.swift
//  JourneyOfFaithApp
//
//  Created by 양승현 on 1/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import Swinject
import DomainEntity
import SettingInterface

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  private(set) var appDIContainer: AppDIContainer!
  
  var window: UIWindow?
  
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    appDIContainer = AppDIContainer()
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    
    let baseVC = UIViewController()
    let naviController = UINavigationController(rootViewController: baseVC)
    baseVC.view.backgroundColor = .palette(.appearance)
    
//    guard let settingGateway = appDIContainer.resolver.resolve(SettingInterface.self) else {
//      fatalError("세팅 게이트웨이 등록 안 됨. 확인바람")
//    }
    let settingViewController = SettingGateway().makeSettingModule(
      navigationController: naviController,
      resolver: appDIContainer.resolver, delegate: self)
    
//    let viewController = SettingViewController()
//    viewController.setSheetStyle()
    
//    let storage = DefaultUserStorageDAO()
//    let repository = DefaultUserSystemSettingsRepository(userStorage: storage)
//    let fontUseCase = DefaultUserSystemSettingFontUseCase(userSystemSettingRepository: repository)
//    let appearanceUseCase = DefaultUserSystemSettingAppearanceUseCase(userSystemSettingRepository: repository)
//    let reactor = SettingReactor(fontUpdateUseCase: fontUseCase, appearanceUpdateUseCase: appearanceUseCase)
//    viewController.reactor = reactor
    window?.rootViewController = naviController
    window?.makeKeyAndVisible()
    baseVC.present(settingViewController, animated: false)
  }
}

// MARK: - SettingCoordinatorDelegate
extension SceneDelegate: SettingCoordinatorDelegate {
  func handleOwnerPickSleepTimerOptionHandler(with option: DomainEntity.SleepTimerOption) {
    print("사용자가 픽한 슬립 옵션을 설정하래요! 아마 슬립 타이머 기반 바이블이 음성으로 들려야 겠죠?")
  }
  
  func handleUpdatedFontSize(with fontSize: CGFloat) {
    print("사용자가 실시간으로 폰트 사이즈를 조정중인가봐요. 어서 폰트 크기를 바꿔봐요! \(fontSize)")
  }
}
