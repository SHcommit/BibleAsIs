//
//  BibleHighlightFetchUseCase.swift
//  DomainInterface
//
//  Created by 양승현 on 2/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol BibleHighlightFetchUseCase {
  func fetchHighlights(for verseId: Int, completion: @escaping (Result<[BibleHighlight], Error>) -> Void)
  
  func fetchHighlights(
    forVerseIdList verseIdList: [Int],
    completion: @escaping (Result<[[BibleHighlight]], Error>) -> Void)
  
  func fetchAllHighlights(completion: @escaping (Result<[[BibleHighlight]], Error>) -> Void)
}
