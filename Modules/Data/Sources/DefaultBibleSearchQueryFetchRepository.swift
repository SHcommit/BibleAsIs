//
//  DefaultBibleSearchQueryFetchRepository.swift
//  Data
//
//  Created by 양승현 on 2/25/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import BibleInterface
import DomainInterface

public final class DefaultBibleSearchQueryFetchRepository: BibleSearchQueryFetchRepository {
  // MARK: - Properties
  private let bibleSearchEngine: BibleSearchable
  
  private let backgroundQueue = DispatchQueue(label: "com.bible.bibleRepository.queue", qos: .userInteractive)
  
  // MARK: - Lifecycle
  public init(bibleSearchEngine: BibleSearchable) {
    self.bibleSearchEngine = bibleSearchEngine
  }
  
  // MARK: - Helpers
  public func fetchQuery(
    _ query: String,
    page: Int = 1,
    pageSize: Int = 20,
    completion: @escaping (Result<(verses: [BibleVerse], totalVerses: Int), any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleSearchEngine.search(query, page: page, pageSize: pageSize) { searchedQueries in
        completion(.success((searchedQueries.verses, searchedQueries.numOfVerses)))
      }
    }
  }
}
