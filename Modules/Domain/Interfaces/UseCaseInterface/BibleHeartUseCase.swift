//
//  BibleHeartUseCase.swift
//  DomainInterface
//
//  Created by 양승현 on 2/18/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import DomainEntity
import Foundation

public protocol BibleHeartFetchUseCase {
  func fetchHeartStatus(for verseId: Int, completion: @escaping (Result<Bool, any Error>) -> Void)
  func fetchAllHearts(completion: @escaping (Result<[BibleHeart], any Error>) -> Void)
  // TODO: - page 패이징 추가햐애햠 ( 피드에선 3개만 가져오거든 )
  func fetchAllLikedVerses(
    completion: @escaping (Result<(hearts: [BibleHeart], verses: [BibleVerse]), any Error>) -> Void
  )
}
