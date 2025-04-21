//
//  DefaultDailyBibleRandomVerseFetchUseCase.swift
//  Domain
//
//  Created by 양승현 on 3/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import DomainInterface

public final class DefaultDailyBibleRandomVerseFetchUseCase: DailyBibleRandomVerseFetchUseCase {
  // MARK: - Dependencies
  private let backgroundQueue = DispatchQueue(
    label: "com.bible.DefaultDailyBibleRandomVerseFetchUseCase.queue",
    qos: .userInteractive)
  
  private let bibleRepository: BibleRepository
  
  private let bibleRandomVerseFetchRepository: DailyBibleRandomVerseFetchRepository
  
  // MARK: - Lifecycle
  public init(
    bibleRepository: BibleRepository,
    bibleRandomVerseFetchRepository: DailyBibleRandomVerseFetchRepository
  ) {
    self.bibleRepository = bibleRepository
    self.bibleRandomVerseFetchRepository = bibleRandomVerseFetchRepository
  }
  
  // MARK: - Helpers
  public func fetchRandomVerse(
    day: Int,
    completion: @escaping (Result<[DomainEntity.BibleVerse], any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else {
        completion(.failure(CommonError.referenceDeallocated))
        return
      }
      
      bibleRandomVerseFetchRepository.fetchRandomVerse(day: day) { [weak self] result in
        guard let self else { return }
        switch result {
        case .success(let bibleRandomVerseEntries):
          if bibleRandomVerseEntries.isEmpty {
            assertionFailure("엥? 데이터 없을리가 없는데 디비에서 불러오는거 테스트 성공했는데? ?")
            completion(.failure(CommonError.noDataFound))
            return
          }
          
          let bibleReferences = bibleRandomVerseEntries.map { BibleReference(book: $0.book, chapter: $0.chapter, verse: $0.verse) }
          bibleRepository.fetchBibleVerses(forReferences: bibleReferences, completion: completion)
        case .failure(let failure):
          completion(.failure(failure))
        }
      }
    }
  }
  
  public func fetchWeeklyRandomVerses(
    fromDay: Int,
    completion: @escaping (Result<[[DomainEntity.BibleVerse]], any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else {
        completion(.failure(CommonError.referenceDeallocated))
        return
      }
      
      bibleRandomVerseFetchRepository.fetchWeeklyRandomVerses(fromDay: fromDay) { [weak self] result in
        guard let self else { return }
        
        switch result {
        case .success(let entriesArray):
          if entriesArray.flatMap({ $0 }).isEmpty {
            assertionFailure("엥? 데이터 없을리가 없는데 디비에서 불러오는거 테스트 성공했는데??")
            completion(.failure(CommonError.noDataFound))
            return
          }
          
          let referencesArray: [[BibleReference]] = entriesArray.map { entries in
            entries.map { BibleReference(book: $0.book, chapter: $0.chapter, verse: $0.verse)}
          }
          
          let group = DispatchGroup()
          var weeklyVerses: [[BibleVerse]] = Array(repeating: [], count: referencesArray.count)
          var unexpectedErrorWhileFetching: Error?
          
          for (index, references) in referencesArray.enumerated() {
            group.enter()
            bibleRepository.fetchBibleVerses(forReferences: references) { result in
              defer { group.leave() }
              switch result {
              case .success(let bibleVerses):
                weeklyVerses[index] = bibleVerses
              case .failure(let failure):
                unexpectedErrorWhileFetching = failure
              }
            }
          }
          
          group.notify(queue: backgroundQueue) {
            if let error = unexpectedErrorWhileFetching {
              completion(.failure(error))
            } else {
              completion(.success(weeklyVerses))
            }
          }
          
        case .failure(let failure):
          completion(.failure(failure))
        }
      }
    }
  }
}
