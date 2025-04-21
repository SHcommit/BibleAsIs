//
//  BibleReadingGardenCommitFetchRepository.swift
//  DomainInterface
//
//  Created by 양승현 on 3/18/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol BibleReadingGardenCommitFetchRepository {
  func fetchMonthlyReadingGardenCommitHistories(
    in year: Int,
    month: Int,
    completion: @escaping (Result<[BibleDailyReadingEntry], any Error>) -> Void)
  
  func fetchAnnualReadingGardenCommitHistories(
    year: Int,
    completion: @escaping (Result<[[BibleDailyReadingEntry]], any Error>) -> Void
  )
}
