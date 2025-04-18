//
//  BibleVerseFetchUseCase.swift
//  DomainInterface
//
//  Created by 양승현 on 2/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol BibleVerseFetchUseCase {
  func fetchBibleVerses(
    forReferences refs: [BibleReference],
    completion: @escaping (Result<[BibleVerse], Error>) -> Void)
  func fetchBibleVerses(
    for book: BibleBook,
    chapter: Int,
    completion: @escaping (Result<[BibleVerse], Error>) -> Void)
  func fetchBibleVerse(
    for book: BibleBook,
    chapter: Int,
    verse: Int,
    completion: @escaping (Result<BibleVerse?, Error>) -> Void)
  func fetchBibleVerse(
    byVerseId id: Int,
    completion: @escaping (Result<BibleVerse?, Error>) -> Void)
}
