//
//  DefaultBibleHeartFetchUseCase.swift
//  Domain
//
//  Created by 양승현 on 2/18/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import DomainInterface

public final class DefaultBibleHeartFetchUseCase: BibleHeartFetchUseCase {
  // MARK: - Properties
  private let bibleRepository: BibleRepository
  
  private let backgroundQueue = DispatchQueue(label: "com.Domain.BibleHeartFetchUseCase.queue")

  // MARK: - Lifecycle
  public init(bibleRepository: BibleRepository) {
    self.bibleRepository = bibleRepository
  }
  
  public func fetchHeartStatus(for verseId: Int, completion: @escaping (Result<Bool, any Error>) -> Void) {
    bibleRepository.fetchHeartStatus(for: verseId, completion: completion)
  }
  
  public func fetchAllHearts(completion: @escaping (Result<[BibleHeart], any Error>) -> Void) {
    bibleRepository.fetchAllHearts(completion: completion)
  }
  
  // swiftlint:disable function_body_length
  public func fetchAllLikedVerses(
    completion: @escaping (Result<(hearts: [BibleHeart], verses: [BibleVerse]), any Error>) -> Void
  ) {
    let dispatchGruop = DispatchGroup()
    let nestedGroup = DispatchGroup()
    var hearts: [BibleHeart]?
    var verses: [BibleVerse]?
    var fetchError: Error?
    
    dispatchGruop.enter()
    fetchAllHearts { result in
      switch result {
      case .success(let fetchedHearts):
        hearts = fetchedHearts
      case .failure(let error):
        fetchError = error
      }
      dispatchGruop.leave()
    }
    
    dispatchGruop.notify(queue: backgroundQueue) { [weak self] in
      guard let self else {
        completion(.failure(CommonError.referenceDeallocated))
        return
      }
      if let fetchError {
        completion(.failure(fetchError))
        return
      }
      
      guard let hearts else {
        completion(.success(([], [])))
        return
      }
      
      let references = hearts.compactMap { heart in
        return BibleReference(bibleReferenceId: heart.verseId)
      }
      
      nestedGroup.enter()
      bibleRepository.fetchBibleVerses(forReferences: references) { verseResults in
        switch verseResults {
        case .success(let fetchedVerses):
          verses = fetchedVerses
        case .failure(let err):
          fetchError = err
        }
        nestedGroup.leave()
      }
      
      nestedGroup.notify(queue: backgroundQueue) {
        if let fetchError {
          completion(.failure(fetchError))
        } else if let verses {
          completion(.success((hearts, verses)))
        } else {
          let nserror = NSError(
            domain: "com.Domain.BibleHeartFetchUseCase",
            code: 1001,
            userInfo: [NSLocalizedDescriptionKey: "Unexpected error occurred while fetching verses."])
          completion(.failure(nserror))
        }
      }
    }
  }
  // swiftlint:enable function_body_length
}
