//
//  BibleHeartDeleteUseCase.swift
//  DomainInterface
//
//  Created by 양승현 on 2/18/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public protocol BibleHeartDeleteUseCase {
  func deleteHeart(byVerseId verseId: Int, completion: @escaping (Result<Void, any Error>) -> Void)
  func deleteHearts(byVerseIdList verseIdList: [Int], completion: @escaping (Result<Void, any Error>) -> Void)
  
  func deleteHeart(byHeartId heartId: Int, completion: @escaping (Result<Void, any Error>) -> Void)
  func deleteHearts(byHeartIdList heartIdList: [Int], completion: @escaping (Result<Void, any Error>) -> Void)
}
