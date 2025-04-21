//
//  SceneDelegate.swift
//  JourneyOfFaithApp
//
//  Created by 양승현 on 1/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import DomainEntity
import BibleNoteInterface

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  private var appDIContainer: AppDIContainer!
  
  var window: UIWindow?
  
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    appDIContainer = AppDIContainer()
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    let gateway = appDIContainer.resolver.resolve(BibleNoteInterface.self)!
    let naviController = UINavigationController()
    
    let baseVC = UIViewController()
    baseVC.view.backgroundColor = .white
    
    let noteViewController = gateway.makeNoteModule(
      navigationController: naviController,
      resolver: appDIContainer.resolver,
      coordinatorDelegate: self,
      bibleNote: nil,
      noteId: nil,
      noteRange: .init(location: 3, length: 10),
      bibleVerse: .init(
        book: .john, chapter: 3, verse: 16,
        content: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life"))
    
    naviController.viewControllers = [baseVC]

    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = naviController
    baseVC.navigationController?.pushViewController(noteViewController, animated: false)
    window?.makeKeyAndVisible()
  }
}

extension SceneDelegate: BibleNoteCoordinatorDelegate {
  // 문제 없음 외부 모듈에서 컨트롤 해주기만 하면됨.
  func handleModifiedNote(modifiedNote: BibleNote?, hasUserModifiedTheNote: Bool, hasUserDeletedTheNote: Bool) {
    print(
          """
            사용자가 노트를 수정했을까요? 
              modifiedNote: \(String(describing: modifiedNote)) 
              hasUserModifiedTheNote: \(hasUserModifiedTheNote) 
              hasUserDeletedTheNote: \(hasUserDeletedTheNote)
          
          """)
  }
}
