//
//  BibleSearchQueryFetchRepository.swift
//  DomainInterface
//
//  Created by 양승현 on 2/25/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol BibleSearchQueryFetchRepository {
  func fetchQuery(
    _ query: String,
    page: Int,
    pageSize: Int,
    completion: @escaping (Result<(verses: [BibleVerse], totalVerses: Int), any Error>) -> Void) 
}
