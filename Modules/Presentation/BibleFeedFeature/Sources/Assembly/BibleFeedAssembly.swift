//
//  BibleFeedAssembly.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 3/28/25.
//

import UIKit
import Common
import Swinject
import ReactorKit
import CoreInterface
import DomainInterface
import BibleFeedInterface

public struct BibleFeedAssembly: Swinject.Assembly {
  public init() { }
  
  public func assemble(container: Swinject.Container) {
    container.register((any Reactor).self, name: BibleFeedReactor._identifier) { r in
      
      guard let readingGardenCommitFetchRepository = r.resolve(BibleReadingGardenCommitFetchRepository.self) else {
        fatalError(errMsgByOuter(type: BibleReadingGardenCommitFetchRepository.self))
      }
      guard let bibleReadingGardenAnalyzer = r.resolve(BibleReadingAnalyzable.self) else {
        fatalError(errMsgByOuter(type: BibleReadingAnalyzable.self))
      }
      guard let calendarService = r.resolve(CalendarServiceProtocol.self) else {
        fatalError(errMsgByOuter(type: CalendarServiceProtocol.self))
      }
      guard let randomVerseFetchUseCase = r.resolve(DailyBibleRandomVerseFetchUseCase.self) else {
        fatalError(errMsgByOuter(type: DailyBibleRandomVerseFetchUseCase.self))
      }
      guard let ownerLastLoginDateUseCase = r.resolve(OwnerLastLoginDateUseCase.self) else {
        fatalError(errMsgByOuter(type: OwnerLastLoginDateUseCase.self))
      }
      guard let recentBibleBookclipUseCase = r.resolve(RecentBibleBookclipUseCase.self) else {
        fatalError(errMsgByOuter(type: RecentBibleBookclipUseCase.self))
      }
      guard let dailyReadingUseCase = r.resolve(DailyBibleReadingChecklistUseCase.self) else {
        fatalError(errMsgByOuter(type: DailyBibleReadingChecklistUseCase.self))
      }
      guard let bibleHeartFetchUseCase = r.resolve(BibleHeartFetchUseCase.self) else {
        fatalError(errMsgByOuter(type: BibleHeartFetchUseCase.self))
      }
      guard let bibleNoteUseCase = r.resolve(BibleNoteUseCase.self) else {
        fatalError(errMsgByOuter(type: BibleNoteUseCase.self))
      }
      guard let bibleVerseFetchUseCase = r.resolve(BibleVerseFetchUseCase.self) else {
        fatalError(errMsgByOuter(type: BibleVerseFetchUseCase.self))
      }
      
      return BibleFeedReactor(
        readingGardenCommitFetchRepository: readingGardenCommitFetchRepository,
        bibleReadingGardenAnalyzer: bibleReadingGardenAnalyzer,
        calendarService: calendarService,
        randomVerseFetchUseCase: randomVerseFetchUseCase,
        ownerLastLoginDateUseCase: ownerLastLoginDateUseCase,
        recentBibleBookclipUseCase: recentBibleBookclipUseCase,
        dailyReadingUseCase: dailyReadingUseCase,
        bibleHeartFetchUseCase: bibleHeartFetchUseCase,
        bibleNoteUseCase: bibleNoteUseCase,
        bibleVerseFetchUseCase: bibleVerseFetchUseCase)
    }
    
    container.register(
      UIViewController.self,
      name: BibleFeedViewController._identifier
    ) { (r, flowDependencies: BibleFeedCoordinator) in
      guard
        let feedReactor = r.resolve((any Reactor).self, name: BibleFeedReactor._identifier) as? BibleFeedReactor
      else { fatalError(errMsgByInner(BibleFeedReactor.self)) }
      let feedViewController = BibleFeedViewController(flowDependencies: flowDependencies)
      feedViewController.reactor = feedReactor
      return feedViewController
    }
    
    container.register(BibleFeedInterface.self) { _ in
      return BibleFeedGateway()
    }
    
    container.register((any Reactor).self, name: FeedSettingReactor._identifier, factory: { r in
      guard let userSystemAppearanceUseCase = r.resolve(UserSystemSettingAppearanceUpdateUseCase.self) else {
        fatalError(errMsgByOuter(type: UserSystemSettingAppearanceUpdateUseCase.self))
      }
      return FeedSettingReactor(userSystemAppearanceUseCase: userSystemAppearanceUseCase)
    })
    
    container.register(
      UIViewController.self,
      name: FeedSettingViewController._identifier
    ) { (r, flowDependencies: BibleFeedCoordinator) in
      guard
        let feedSettingReactor = r.resolve(
          (any Reactor).self,
          name: FeedSettingReactor._identifier
        )  as? FeedSettingReactor
      else { fatalError(errMsgByInner(FeedSettingReactor.self)) }
      let viewController = FeedSettingViewController(flowDependencies: flowDependencies)
      viewController.reactor = feedSettingReactor
      return viewController
    }
  }
}
