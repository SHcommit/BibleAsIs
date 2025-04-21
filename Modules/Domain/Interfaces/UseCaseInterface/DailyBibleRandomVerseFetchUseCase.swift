//
//  DailyBibleRandomVerseFetchUseCase.swift
//  DomainInterface
//
//  Created by 양승현 on 3/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol DailyBibleRandomVerseFetchUseCase {
  func fetchRandomVerse(day: Int, completion: @escaping (Result<[BibleVerse], Error>) -> Void)
  
  func fetchWeeklyRandomVerses(fromDay: Int, completion: @escaping (Result<[[BibleVerse]], Error>) -> Void)
}
