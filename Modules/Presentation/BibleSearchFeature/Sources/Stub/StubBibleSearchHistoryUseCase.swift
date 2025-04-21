//
//  StubBibleSearchHistoryUseCase.swift
//  BibleSearchFeature
//
//  Created by 양승현 on 2/25/25.
//

import Foundation
import DomainEntity
import DomainInterface

final class StubBibleSearchHistoryUseCase: BibleSearchHistoryUseCase {
  func addBibleSearchHistory(
    bibleRef ref: DomainEntity.BibleReference,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    completion(.success(()))
  }
  
  func fetchAllGroupedSearchHistory(
    completion: @escaping (Result<[[DomainEntity.BibleSearchHistory]], any Error>) -> Void
  ) {
    completion(.success([]))
  }
  
  func deleteBibleSearchHistories(
    forYear year: String, month: String, day: String, completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    completion(.success(()))
  }
}
