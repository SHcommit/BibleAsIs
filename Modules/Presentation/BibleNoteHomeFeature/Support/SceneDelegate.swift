//
//  SceneDelegate.swift
//  JourneyOfFaithApp
//
//  Created by 양승현 on 1/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import Swinject
import BibleNoteHomeFeature

// MARK: - forTest
// import Data
// import Bible
// import DomainEntity

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  private(set) var appDIContainer = AppDIContainer()
  
  var window: UIWindow?
//  let repo = DefaultBibleRepository(
//    bibleDAO: DefaultBibleDAO(databaseLoader: DefaultBibleDatabaseLoader()))
  
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
//    repo.fetchNotes(page: 1, pageSize: 10, completion: { res in
//      switch res {
//      case .success(let success):
//        if success.totalNotes == 0 {
//          /// 비었을 때 단 한번!
//          self.repo.addNote(
//            verseId: BibleReference(book: .acts, chapter: 1, verse: 1).id,
//            text: "메모작성 메모메모\n노트임!",
//            range: NSRange(location: 3, length: 10)) { _ in }
//          self.repo.addNote(
//            verseId: BibleReference(book: .genesis, chapter: 2, verse: 3).id,
//            text: "메모작성 메모메모\n\n\n노트트트트트트트트트트트\n노트임!",
//            range: NSRange(location: 3, length: 10)) { _ in }
//          self.repo.addNote(
//            verseId: BibleReference(book: .john, chapter: 3, verse: 16).id,
//            text: "메모작성 메모메모\n\n\n\n\n\n\n\n\n\n노트노트노트\n\n메모메모\n\n\n노트노튼노노노노노노노트트트트트트트트트트트트\n노트임",
//            range: NSRange(location: 3, length: 16)) { _ in }
//          
//          for i in (0..<45) {
//            self.repo.addNote(
//              verseId: BibleReference(book: .psalms, chapter: i+1, verse: 1).id,
//              text: "메모작성 메모메모\n노트임!",
//              range: NSRange(location: 3, length: 5)) { _ in }
//          }
//          print("고고 디비에추가 ")
//        }
//        
//      case .failure(let failure):
//        print("노트 추가하려했는데 에러:\(failure.localizedDescription)")
//      }
//    })

    let navi = UINavigationController()
//    let gateway = appDIContainer.resolver.resolve(BibleNoteHomeInterface.self)!
//    let vc = gateway.makeBibleNoteHomeModule(
//      navigationController: navi,
//      resolver: appDIContainer.resolver,
//      forPageViewMode: false)
    let vc = BibleNoteHomeGateway().makeBibleNoteHomeModule(
      navigationController: navi,
      resolver: appDIContainer.resolver,
      forPageViewMode: false)
    navi.viewControllers = [vc]
    
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = navi
    window?.makeKeyAndVisible()
  }
}
