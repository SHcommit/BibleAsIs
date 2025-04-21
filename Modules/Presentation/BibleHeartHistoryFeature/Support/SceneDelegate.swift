//
//  SceneDelegate.swift
//  BibleHeartHistoryFeatureDemoApp
//
//  Created by 양승현 on 3/27/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import Swinject
import BibleHeartHistoryFeature

// for Tests
import Data
import Bible
import DomainEntity

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
#if DEBUG
  /// forTests
  /// 처음 시작 scene(_:willConnectTo:options:) 함수 내부에 이거 레포지토리 선언해서 백그라운드나 뭐 무작위로  돌리면 이거 실행은
  /// 이 함수의 컨텍스트가 끝남과 동시에 메모리에서 해제되니까,, 레포지토리가 계속핵서 비동기로 수행이안됨,, 수행한다 해도 중간에 특정
  /// 인스턴스가 없어져서 디비에 못올림(특히 이거 내부적으로 백그라운드 스레드 써서 )
  /// 그래서 외부에서 선언하고 내부에선 캡쳐해서 실행할수있게 프로퍼티로 뺌
  let repo = DefaultBibleRepository(
    bibleDAO: DefaultBibleDAO(databaseLoader: DefaultBibleDatabaseLoader(), rootQueue: DispatchQueue.global(qos: .userInitiated)))
#endif
  
  private(set) var appDIContainer = AppDIContainer()
  
  var window: UIWindow?
  
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    
    guard let windowScene = (scene as? UIWindowScene) else { return }
    /// for Tests
#if DEBUG
    repo.fetchAllHearts { result in
      if case .success(let success) = result {
        if success.isEmpty {
          self.repo.toggleHeartStatus(for: BibleReference.getId(book: .genesis, chapter: 1, verse: 1), isOnHeart: true) { _ in }
          self.repo.toggleHeartStatus(for: BibleReference.getId(book: .genesis, chapter: 1, verse: 2), isOnHeart: true) { _ in }
          self.repo.toggleHeartStatus(for: BibleReference.getId(book: .genesis, chapter: 1, verse: 3), isOnHeart: true) { _ in }
          self.repo.toggleHeartStatus(for: BibleReference.getId(book: .matthew, chapter: 1, verse: 4), isOnHeart: true) { _ in }
        }
      }
    }
#endif
    
    let navi = UINavigationController()
//    let gateway = appDIContainer.resolver.resolve(BibleHeartHistoryInterface.self)!
//    let vc = gateway.makeBibleHeartHistoryModule(
//      navigationController: navi,
//      resolver: appDIContainer.resolver,
//      forPageViewMode: false)
    let vc = BibleHeartHistoryGateway().makeBibleHeartHistoryModule(
      navigationController: navi,
      resolver: appDIContainer.resolver,
      forPageViewMode: false)
    navi.viewControllers = [vc]
    
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = navi
    window?.makeKeyAndVisible()
  }
}
