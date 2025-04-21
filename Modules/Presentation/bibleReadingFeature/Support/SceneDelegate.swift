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
import DesignSystemItems
import BibleReadingFeature

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
    baseVC.view.backgroundColor = .white
    let navVC = UINavigationController(rootViewController: baseVC)
    window?.rootViewController = navVC
    
    let startEntry = BibleReadingEntryItem(bibleBook: .matthew, chapter: 1)
    /// endEntry
    /// 지금 미사용. 테스트할때 사용
    _=BibleReadingEntryItem(bibleBook: .matthew, chapter: 4)
    
// MARK: - 범위 1 개 OK
//    let paginationController = BibleReadingPaginationController(
//      currentReadingEntryItem: startEntry,
//      bibleReadingEntryItemsForRange: [startEntry],
//      isRestrictEntry: true)
    
// MARK: - 범위 2 개 OK
//    let paginationController = BibleReadingPaginationController(
//      currentReadingEntryItem: startEntry,
//      bibleReadingEntryItemsForRange: [startEntry, endEntry],
//      isRestrictEntry: true)
    
// MARK: - 범위 5 개 OK
//    endEntry.chapter = 5
//    let paginationController = BibleReadingPaginationController(
//      currentReadingEntryItem: startEntry,
//      bibleReadingEntryItemsForRange: [startEntry, endEntry],
//      isRestrictEntry: true)
    
// MARK: - free모드 테스트. OK
//    let paginationController = BibleReadingPaginationController(
//      currentReadingEntryItem: startEntry,
//      bibleReadingEntryItemsForRange: [],
//      isRestrictEntry: false)
    
// MARK: - 오디오 테스트 모드 가장 짧은 chapter. OK
//    let _startEntry = BibleReadingEntryItem(bibleBook: .psalms, chapter: 117)
//    let _startEntry = BibleReadingEntryItem(bibleBook: .john, chapter: 3)
    
//    let paginationController = BibleReadingPaginationController(
//      currentReadingEntryItem: _startEntry,
//      bibleReadingEntryItemsForRange: [],
//      isRestrictEntry: false)
//    
//    let tempCoord = TempCoord(naviController: navVC)
//    let biblePaginationViewController = BibleReadingContainerViewController(
//      paginationController: paginationController, tempCoord: tempCoord)
//    
//    baseVC.navigationController?.pushViewController(biblePaginationViewController, animated: false)
    
//    let gateway = appDIContainer.resolver.resolve(bibleReadingInterface.self)
//    guard let vc = gateway?.makeBibleContentPaginationModule(
//      navigationController: navVC,
//      resolver: appDIContainer.resolver,
//      currentReadingEntryItem: startEntry,
//      bibleReadingEntryItemsForRange: [],
//      isRestrictEntry: false
//    ) else { fatalError("뭔가 등록 안됨 확인바람") }
    
//    guard let vc = BibleReadingGateway().makeBibleContentPaginationModule(
//      navigationController: navVC,
//      resolver: appDIContainer.resolver,
//      currentReadingEntryItem: startEntry,
//      bibleReadingEntryItemsForRange: [],
//      isRestrictEntry: false
//    ) else { fatalError("뭔가 등록 안됨 확인바람") }
    let vc = BibleReadingGateway().makeBibleContentPaginationModule(
      navigationController: navVC,
      resolver: appDIContainer.resolver,
      currentReadingEntryItem: startEntry,
      bibleReadingEntryItemsForRange: [],
      isRestrictEntry: false
    )
    
    baseVC.navigationController?.pushViewController(vc, animated: false)
    
    window?.makeKeyAndVisible()
  }
}
