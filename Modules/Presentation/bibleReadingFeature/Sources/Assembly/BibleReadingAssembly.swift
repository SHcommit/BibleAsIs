//
//  BibleReadingAssembly.swift
//  BibleReadingFeature
//
//  Created by 양승현 on 3/25/25.
//

import UIKit
import Common
import Swinject
import ReactorKit
import CoreInterface
import DomainInterface
import DesignSystemItems
import BibleReadingInterface

public struct BibleReadingAssembly: Swinject.Assembly {  
  func errMsgByOuter<T>(type: T.Type) -> String {
    String.registrationErrorMsgByOuter(type: type, inAssembly: Self.self)
  }
  
  func errMsgByInner<T>(_: T.Type) -> String {
    String.registrationErrorMsgByInner(T.self)
  }
  
  public init() { }
  
  public func assemble(container: Container) {
    // MARK: - BibleReading
    container.register(
      (any Reactor).self,
      name: BibleReadingReactor._identifier
    ) { (r, currentReadingEntryItem: BibleReadingEntryItem, readingEntryItemsForRange: [BibleReadingEntryItem], isRestrictEntry: Bool) in
      guard let calendarService = r.resolve(CalendarServiceProtocol.self) else {
        fatalError(errMsgByOuter(type: CalendarServiceProtocol.self))
      }
      
      guard let bibleRepository = r.resolve(BibleRepository.self) else {
        fatalError(errMsgByOuter(type: BibleRepository.self))
      }
      
      guard let recentBibleBookRepository = r.resolve(RecentBibleBookclipRepository.self) else {
        fatalError(errMsgByOuter(type: RecentBibleBookclipRepository.self))
      }
      
      guard let fontSystemSettingFetchUseCase = r.resolve(UserSystemSettingFontUseCase.self) else {
        fatalError(errMsgByOuter(type: UserSystemSettingFontUseCase.self))
      }
      
      guard let bibleReadingGardenSaveUseCase = r.resolve(BibleReadingGardenSaveUseCase.self) else {
        fatalError(errMsgByOuter(type: BibleReadingGardenSaveUseCase.self))
      }
      
      guard let sleepTimeHandleRepository = r.resolve(SleepTimeHandleRepository.self) else {
        fatalError(errMsgByOuter(type: SleepTimeHandleRepository.self))
      }
      
      return BibleReadingReactor(
          currentReadingEntryItem: currentReadingEntryItem,
          bibleReadingEntryItemsForRange: readingEntryItemsForRange,
          isRestrictEntry: isRestrictEntry,
          calendarService: calendarService,
          bibleRepository: bibleRepository,
          recentBibleBookclipRepository: recentBibleBookRepository,
          fontSystemSettingsFetchUseCase: fontSystemSettingFetchUseCase,
          bibleReadingGardenSaveUseCase: bibleReadingGardenSaveUseCase,
          sleepTimeHandleRepository: sleepTimeHandleRepository)
    }
    
    container.register(
      UIViewController.self,
      name: BibleReadingViewController._identifier
    ) { (r, flowDependencies: BibleReadingCoordinator, entryBySleepAudioPlay: Bool, delegate: BibleReadingViewControllerDelegate?, currentReadingEntryItem: BibleReadingEntryItem, readingEntryItemsForRange: [BibleReadingEntryItem], isRestrictEntry: Bool) in
      guard
        let bibleReadingReactor = r.resolve(
          (any Reactor).self,
          name: BibleReadingReactor._identifier,
          arguments: currentReadingEntryItem, readingEntryItemsForRange, isRestrictEntry
        ) as? BibleReadingReactor else { fatalError(errMsgByInner(BibleReadingReactor.self)) }
      
      let bibleReadingViewController =  BibleReadingViewController(
        flowDependencies: flowDependencies,
        entryBySleepAudioPlay: entryBySleepAudioPlay,
        delegate: delegate,
        sleepAudioPlayerFactory: { dataSource in
          return r.resolve(BibleSleepAudioPlayerProtocol.self, argument: dataSource)
        })
      
      bibleReadingViewController.reactor = bibleReadingReactor
      return bibleReadingViewController
    }    
    
    container.register(bibleReadingInterface.self) { _ in
      BibleReadingGateway()
    }
  }
}
