//
//  DailyReadingChecklistRepository.swift
//  DomainInterface
//
//  Created by 양승현 on 3/3/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol DailyReadingChecklistRepository {
  func fetchAlreadyReadEntries(
    book: BibleBook,
    completion: @escaping (Result<[DailyBibleReadingChapterEntry], any Error>) -> Void)
  
  func update(
    _ entry: DailyBibleReadingChapterEntry,
    completion: @escaping (Result<Void, any Error>) -> Void)
  
  func insert(
    _ entry: DailyBibleReadingChapterEntry,
    completion: @escaping (Result<Void, any Error>) -> Void)
}
