//
//  BibleReadingGardenLogRepository.swift
//  DomainInterface
//
//  Created by 양승현 on 3/14/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol BibleReadingGardenLogRepository {
  func fetchBibleReadingGardenLogCommitsForMomth(
    year: Int,
    month: Int,
    completion: @escaping (Result<[BibleReadingGardenLogEntry], Error>) -> Void)
  
  func fetchBibleReadingGardenLogCommitsForYear(
    year: Int,
    completion: @escaping (Result<[BibleReadingGardenLogEntry], Error>) -> Void)
  func fetchBibleReadingGardenLogCommitsForDay(
    year: Int,
    month: Int,
    day: Int,
    completion: @escaping (Result<BibleReadingGardenLogEntry?, Error>) -> Void)
  
  func saveBibleReadingGardenForDay(
    _ newEntry: BibleReadingGardenLogEntry,
    completion: @escaping (Result<Void, Error>) -> Void)
  
  func didLogReadingOnDay(
    _ entry: BibleReadingGardenLogEntry,
    completion: @escaping (Result<Bool, Error>) -> Void)
  
  func delete(_ entry: BibleReadingGardenLogEntry, completion: @escaping (Result<Void, Error>) -> Void)
}
