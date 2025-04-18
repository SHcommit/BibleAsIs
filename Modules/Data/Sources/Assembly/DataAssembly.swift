//
//  DataAssembly.swift
//  Data
//
//  Created by 양승현 on 3/23/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Swinject
import Foundation
import CoreInterface
import BibleInterface
import DomainInterface

public final class DataAssembly: Assembly {
  
  public init() { }
  
  public func assemble(container: Container) {
    // MARK: - Owner
    container.register(OwnerBibleMccCheyneRepository.self) { r in
      guard let defaultUserStorage = r.resolve(UserStorageProtocol.self) else {
        fatalError("UserStorageProtocol 등록 해주세요")
      }
      
      return DefaultOwnerBibleMccCheyneRepository(storage: defaultUserStorage)
    }
    
    container.register(OwnerLastLoginDateRepository.self) { r in
      guard let defaultUserStorage = r.resolve(UserStorageProtocol.self) else {
        fatalError("UserStorageProtocol 등록 해주세요")
      }
      return DefaultOwnerLastLoginDateRepository(userStorage: defaultUserStorage)
    }
    
    container.register(RecentBibleBookclipRepository.self) { r in
      guard let defaultUserStorage = r.resolve(UserStorageProtocol.self) else {
        fatalError("UserStorageProtocol 등록 해주세요")
      }
      return DefaultRecentBibleBookclipRepository(userStorage: defaultUserStorage)
    }
    
    container.register(SleepTimeHandleRepository.self) { r in
      guard let defaultUserStorage = r.resolve(UserStorageProtocol.self) else {
        fatalError("UserStorageProtocol 등록 해주세요")
      }
      return DefaultSleepTimeHandleRepository(userStorage: defaultUserStorage)
    }
      
    container.register(UserSystemSettingsRepository.self) { r in
      guard let defaultUserStorage = r.resolve(UserStorageProtocol.self) else {
        fatalError("UserStorageProtocol 등록 해주세요")
      }
      return DefaultUserSystemSettingsRepository(userStorage: defaultUserStorage)
    }
    
    // MARK: - DAO
    
    container.register(BibleReadingGardenTrackable.self) { r in
      guard let calendarService = r.resolve(CalendarServiceProtocol.self) else {
        fatalError("calendar service 등록 해주세요")
      }
      
      guard let readingGardenCommitDAO = r.resolve(BibleReadingGardenCommitDAO.self) else {
        fatalError("reading garden commit DAO 등록해주세요")
      }
      
      return BibleReadingGardenCommitTracker(
        calendarService: calendarService,
        readingGardenCommitDAO: readingGardenCommitDAO)
    }
    
    container.register(BibleMccCheyneRepository.self) { r in
      guard let mccCheyneDAO = r.resolve(BibleMccCheyneDAO.self) else {
        fatalError("mcc cheyne dao 등록해야 합니다")
      }
      return DefaultBibleMccCheyneRepository(dbManager: mccCheyneDAO)
    }
    
    container.register(BibleReadingGardenCommitFetchRepository.self) { r in
      guard let bibleReadingGardenCommitDAO = r.resolve(BibleReadingGardenCommitDAO.self) else {
        fatalError("Bible reading garden commit dao 등록하기")
      }
      
      return DefaultBibleReadingGardenCommitFetchRepository(gardenCommitDAO: bibleReadingGardenCommitDAO)
    }
    
    container.register(BibleReadingGardenLogRepository.self) { r in
      guard let bibleReadingGardenLogDAO = r.resolve(BibleReadingGardenLogDAO.self) else {
        fatalError("bible reading garden log DAO 등록 하기")
      }
      return DefaultBibleReadingGardenLogRepository(readingGardenLogDAO: bibleReadingGardenLogDAO)
    }
    
    container.register(BibleRecentlySearchedQueryRepository.self) { r in
      guard let defaultUserStorageDAO = r.resolve(UserStorageProtocol.self) else {
        fatalError(" User Storage Protocol 등록하기")
      }
      return DefaultBibleRecentlySearchedQueryRepository(storage: defaultUserStorageDAO)
    }
    
    container.register(BibleRepository.self) { r in
      guard let bibleDAO = r.resolve(BibleDAO.self) else {
        fatalError("bible DAO 등록하긔")
      }
      return DefaultBibleRepository(bibleDAO: bibleDAO)
    }
    
    container.register(BibleSearchQueryFetchRepository.self) { r in
      guard let bibleSearchEngine = r.resolve(BibleSearchable.self) else {
        fatalError("bible search engine 등록하긔")
      }
      
      return DefaultBibleSearchQueryFetchRepository(bibleSearchEngine: bibleSearchEngine)
    }
    
    container.register(DailyBibleRandomVerseFetchRepository.self) { r in
      guard let dailyBibleRandomVerseDAO = r.resolve(DailyBibleRandomVerseDAO.self) else {
        fatalError("DailyBibleRandomVerseDAO 등록 하긔~")
      }
      return DefaultDailyBibleRandomVerseFetchRepository(dailyBibleRandomVerseDAO: dailyBibleRandomVerseDAO)
    }
    
    container.register(DailyReadingChecklistRepository.self) { r in
      guard let bibleReadingChecklistDAO = r.resolve(DailyBibleReadingChecklistDAO.self) else {
        fatalError("DailyBibleReadingChecklsitDAO 등록해야함")
      }
      return DefaultDailyReadingChecklistRepository(bibleReadingChecklistDAO: bibleReadingChecklistDAO)
    }
    
    container.register(DailyReadingProgressRepository.self) { r in
      guard let defaultUserStorageDAO = r.resolve(UserStorageProtocol.self) else {
        fatalError(" User Storage Protocol 등록하기")
      }
      return DefaultDailyReadingProgressRepository(fileStorage: defaultUserStorageDAO)
    }
  }
}
