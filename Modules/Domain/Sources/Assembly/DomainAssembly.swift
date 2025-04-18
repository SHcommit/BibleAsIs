//
//  DomainAssembly.swift
//  Domain
//
//  Created by 양승현 on 3/23/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Swinject
import Foundation
import DomainEntity
import DomainInterface

public final class DomainAssembly: Swinject.Assembly {
  public init() { }
  public func assemble(container: Container) {
    // MARK: - BibleReadingGarden
    container.register(BibleReadingGardenDeleteUseCase.self) { r in
      guard let readingGardenTracker = r.resolve(BibleReadingGardenTrackable.self) else {
        fatalError("BibleReadingGardenTrackable 등록 안하거나 DataAssembly 추가 누락됨 잘 봐바")
      }
      
      guard let bibleReadingGardenLogRepository = r.resolve(BibleReadingGardenLogRepository.self) else {
        fatalError("BibleReadingGardenLogRepository 등록 안하거나 DataAssembly 추가 누락됨 잘 봐바")
      }
      
      return DefaultBibleReadingGardenDeleteUseCase(
        tracker: readingGardenTracker,
        gardenLogRepository: bibleReadingGardenLogRepository)
    }
    
    container.register(BibleReadingGardenSaveUseCase.self) { r in
      guard let readingGardenTracker = r.resolve(BibleReadingGardenTrackable.self) else {
        fatalError("BibleReadingGardenTrackable 등록 안하거나 DataAssembly 추가 누락됨 잘 봐바")
      }
      
      guard let bibleReadingGardenLogRepository = r.resolve(BibleReadingGardenLogRepository.self) else {
        fatalError("BibleReadingGardenLogRepository 등록 안하거나 DataAssembly 추가 누락됨 잘 봐바")
      }
      
      return DefaultBibleReadingGardenSaveUseCase(
        tracker: readingGardenTracker,
        gardenLogRepository: bibleReadingGardenLogRepository)
    }
    
    // MARK: - SystemSettings
    container.register(UserSystemSettingAppearanceUpdateUseCase.self) { r in
      guard let userSystemSettingsRepository = r.resolve(UserSystemSettingsRepository.self) else {
        fatalError("UserSystemSettingsRepository 등록 안하거나 DataAssembly 추가 누락됨 잘 봐바")
      }
      
      return DefaultUserSystemSettingAppearanceUseCase(userSystemSettingRepository: userSystemSettingsRepository)
    }
    
    container.register(UserSystemSettingFontUseCase.self) { r in
      guard let userSystemSettingsRepository = r.resolve(UserSystemSettingsRepository.self) else {
        fatalError("UserSystemSettingsRepository 등록 안하거나 DataAssembly 추가 누락됨 잘 봐바")
      }
      
      return DefaultUserSystemSettingFontUseCase(userSystemSettingRepository: userSystemSettingsRepository)
    }
    
    // MARK: - Heart
    container.register(BibleHeartDeleteUseCase.self) { r in
      guard let bibleRepository = r.resolve(BibleRepository.self) else {
        fatalError("BibleRepository 등록 안하거나 DataAssembly 추가 누락됨 잘 봐바")
      }
      return DefaultBibleHeartDeleteUseCase(bibleRepository: bibleRepository)
    }
    
    container.register(BibleHeartFetchUseCase.self) { r in
      guard let bibleRepository = r.resolve(BibleRepository.self) else {
        fatalError("BibleRepository 등록 안하거나 DataAssembly 추가 누락됨 잘 봐바")
      }
      
      return DefaultBibleHeartFetchUseCase(bibleRepository: bibleRepository)
    }
    
    // MARK: - Highlight
    container.register(BibleHighlightFetchUseCase.self) { r in
      guard let bibleRepository = r.resolve(BibleRepository.self) else {
        fatalError("BibleRepository 등록 안하거나 DataAssembly 추가 누락됨 잘 봐바")
      }
      
      return DefaultBibleHighlightFetchUseCase(repo: bibleRepository)
    }
    
    // MARK: - Note
    container.register(BibleNoteUseCase.self) { r in
      guard let bibleRepository = r.resolve(BibleRepository.self) else {
        fatalError("BibleRepository 등록 안하거나 DataAssembly 추가 누락됨 잘 봐바")
      }
      
      return DefaultBibleNoteUseCase(bibleRepository: bibleRepository)
    }
    
    // MARK: - Search
    container.register(BibleSearchHistoryUseCase.self) { r in
      guard let bibleRepository = r.resolve(BibleRepository.self) else {
        fatalError("BibleRepository 등록 안하거나 DataAssembly 추가 누락됨 잘 봐바")
      }
      
      return DefaultBibleSearchHistoryUseCase(bibleRepository: bibleRepository)
    }
    
    // MARK: - Bible verse
    container.register(BibleVerseFetchUseCase.self) { r in
      guard let bibleRepository = r.resolve(BibleRepository.self) else {
        fatalError("BibleRepository 등록 안하거나 DataAssembly 추가 누락됨 잘 봐바")
      }
      
      return DefaultBibleVerseFetchUseCase(bibleRepository: bibleRepository)
    }
    
    container.register(DailyBibleRandomVerseFetchUseCase.self) { r in
      guard let bibleRepository = r.resolve(BibleRepository.self) else {
        fatalError("BibleRepository 등록 안하거나 DataAssembly 추가 누락됨 잘 봐바")
      }
      
      guard let bibleRandomVerseFetchRepository = r.resolve(DailyBibleRandomVerseFetchRepository.self) else {
        fatalError("DailyBibleRandomVerseFetchRepository 등록 안하거나 DataAssembly 추가 누락됨 잘 봐바")
      }
      
      return DefaultDailyBibleRandomVerseFetchUseCase(
        bibleRepository: bibleRepository,
        bibleRandomVerseFetchRepository: bibleRandomVerseFetchRepository)
    }
    
    container.register(DailyBibleReadingChecklistUseCase.self) { r in
      guard let dailyReadingChecklistRepository = r.resolve(DailyReadingChecklistRepository.self) else {
        fatalError("dailyReadingChecklistRepository 등록 안하거나 DataAssembly 추가 누락됨 잘 봐바")
      }
      
      guard let dailyReadingProgressRepository = r.resolve(DailyReadingProgressRepository.self) else {
        fatalError("dailyReadingProgressRepository 등록 안하거나 DataAssembly 추가 누락됨 잘 봐바")
      }
      
      return DefaultDailyBibleReadingChecklistUseCase(
        dailyReadingChecklistRepository: dailyReadingChecklistRepository,
        dailyReadingProgressRepository: dailyReadingProgressRepository)
    }
    
    container.register(OwnerLastLoginDateUseCase.self) { r in
      guard let ownerLastLoginDateRepository = r.resolve(OwnerLastLoginDateRepository.self) else {
        fatalError("ownerLastLoginDateRepository 등록 안하거나 DataAssembly 추가 누락됨 잘 봐바")
      }
      
      return DefaultOwnerLastLoginDateUseCase(ownerLastLoginDateRepository: ownerLastLoginDateRepository)
    }
    
    container.register(RecentBibleBookclipUseCase.self) { r in
      guard let bibleRepository = r.resolve(BibleRepository.self) else {
        fatalError("BibleRepository 등록 안하거나 DataAssembly 추가 누락됨 잘 봐바")
      }
      
      guard let recentBibleBookclipRepository = r.resolve(RecentBibleBookclipRepository.self) else {
        fatalError("recentBibleBookclipRepository 등록 안하거나 DataAssembly 추가 누락됨 잘 봐바")
      }
      
      return DefaultRecentBibleBookclipUseCase(
        recentBookclipRepository: recentBibleBookclipRepository,
        bibleRepository: bibleRepository)
    }
  }
}
