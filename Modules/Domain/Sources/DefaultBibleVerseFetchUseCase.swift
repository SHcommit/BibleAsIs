//
//  DefaultBibleVerseFetchUseCase.swift
//  Domain
//
//  Created by 양승현 on 2/24/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import DomainInterface

public final class DefaultBibleVerseFetchUseCase: BibleVerseFetchUseCase {
  // MARK: - Properties
  private let bibleRepository: BibleRepository
  
  // MARK: - Lifecycle
  public init(bibleRepository: BibleRepository) {
    self.bibleRepository = bibleRepository
  }
  
  public func fetchBibleVerses(
    forReferences refs: [DomainEntity.BibleReference],
    completion: @escaping (Result<[DomainEntity.BibleVerse], any Error>
    ) -> Void) {
    bibleRepository.fetchBibleVerses(forReferences: refs, completion: completion)
  }
  
  public func fetchBibleVerses(
    for book: DomainEntity.BibleBook,
    chapter: Int,
    completion: @escaping (Result<[DomainEntity.BibleVerse], any Error>
    ) -> Void) {
    bibleRepository.fetchBibleVerses(for: book, chapter: chapter, completion: completion)
  }
  
  public func fetchBibleVerse(
    for book: DomainEntity.BibleBook,
    chapter: Int,
    verse: Int,
    completion: @escaping (Result<DomainEntity.BibleVerse?, any Error>) -> Void
  ) {
    bibleRepository.fetchBibleVerse(for: book, chapter: chapter, verse: verse, completion: completion)
  }
  
  public func fetchBibleVerse(
    byVerseId id: Int,
    completion: @escaping (Result<DomainEntity.BibleVerse?, any Error>
    ) -> Void) {
    guard let bibleRef = BibleReference.init(bibleReferenceId: id) else {
      completion(.success(nil))
      return
    }
    bibleRepository.fetchBibleVerse(
      for: bibleRef.book,
      chapter: bibleRef.chapter,
      verse: bibleRef.verse,
      completion: completion)
  }
}
