//
//  BibleSearchHistoryUseCase.swift
//  Domain
//
//  Created by 양승현 on 2/24/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol BibleSearchHistoryUseCase {
  func addBibleSearchHistory(
    bibleRef ref: BibleReference,
    completion: @escaping (Result<Void, any Error>) -> Void)
  
  /// 1차원 배열은 yyyy-MM-dd 같은거
  /// 일단 페이징 지원 x
  func fetchAllGroupedSearchHistory(
    completion: @escaping (Result<[[BibleSearchHistory]], any Error>) -> Void)
  
  func deleteBibleSearchHistories(
    forYear year: String,
    month: String,
    day: String,
    completion: @escaping (Result<Void, any Error>) -> Void)

}
