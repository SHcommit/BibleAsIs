//
//  DefaultBibleHighlightFetchUseCase.swift
//  Domain
//
//  Created by 양승현 on 2/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import DomainInterface

public final class DefaultBibleHighlightFetchUseCase: BibleHighlightFetchUseCase {
  // MARK: - Dependencies
  private let repo: BibleRepository
  
  // MARK: - Lifecycle
  public init(repo: BibleRepository) {
    self.repo = repo
  }
  
  // MARK: - Helpers
  
  public func fetchHighlights(
    for verseId: Int,
    completion: @escaping (Result<[DomainEntity.BibleHighlight], any Error>) -> Void
  ) {
    repo.fetchHighlights(for: verseId, completion: completion)
  }
  
  public func fetchHighlights(
    forVerseIdList verseIdList: [Int],
    completion: @escaping (Result<[[BibleHighlight]], any Error>) -> Void
  ) {
    let group = DispatchGroup()
    var highlights: [[BibleHighlight]] = []
    var fetchError: Error?
    
    for verseId in verseIdList {
      group.enter()
      repo.fetchHighlights(for: verseId) { result in
        switch result {
        case .success(let highlight):
          highlights.append(highlight)
        case .failure(let error):
          fetchError = error
        }
        group.leave()
      }
    }
    
    group.notify(queue: .global(qos: .default)) {
      if let fetchError {
        completion(.failure(fetchError) )
      } else {
        completion(.success(highlights))
      }
    }
  }
  
  /// 테이블에 있는 모든 record 받아와서 시간순 정렬 + verseId로 그룹화 한 highlights를 배열로 반환
  public func fetchAllHighlights(completion: @escaping (Result<[[DomainEntity.BibleHighlight]], any Error>) -> Void) {
    repo.fetchAllHighlights(completion: completion)
  }  
}
