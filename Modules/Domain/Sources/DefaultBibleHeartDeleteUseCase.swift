//
//  DefaultBibleHeartDeleteUseCase.swift
//  Domain
//
//  Created by 양승현 on 2/18/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainInterface

public final class DefaultBibleHeartDeleteUseCase: BibleHeartDeleteUseCase {
  private let bibleRepository: BibleRepository
  
  private let backgroundQueue = DispatchQueue(label: "com.Domain.BibleHeartDeleteUseCase.queue")
  
  public init(bibleRepository: BibleRepository) {
    self.bibleRepository = bibleRepository
  }
  
  public func deleteHeart(byVerseId verseId: Int, completion: @escaping (Result<Void, any Error>) -> Void) {
    bibleRepository.toggleHeartStatus(for: verseId, isOnHeart: false, completion: completion)
  }
  
  public func deleteHeart(byHeartId heartId: Int, completion: @escaping (Result<Void, any Error>) -> Void) {
    bibleRepository.deleteHeart(byHeartId: heartId, completion: completion)
  }
  
  public func deleteHearts(
    byVerseIdList verseIdList: [Int],
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    let dispatchGroup = DispatchGroup()
    var deletionError: Error?
    
    for verseId in verseIdList {
      dispatchGroup.enter()
      
      deleteHeart(byVerseId: verseId) { result in
        if case .failure(let error) = result {
          deletionError = error
        }
        dispatchGroup.leave()
      }
    }
    
    dispatchGroup.notify(queue: backgroundQueue) {
      if let deletionError {
        completion(.failure(deletionError))
      } else {
        completion(.success(()))
      }
    }
  }
  
  public func deleteHearts(
    byHeartIdList heartIdList: [Int],
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    let group = DispatchGroup()
    var delectionError: Error?
    
    for heartId in heartIdList {
      group.enter()
      deleteHeart(byHeartId: heartId) { result in
        if case .failure(let error) = result {
          delectionError = error
        }
        group.leave()
      }
    }
    group.notify(queue: backgroundQueue) {
      if let delectionError {
        completion(.failure(delectionError))
      } else {
        completion(.success(()))
      }
    }
  }
}
