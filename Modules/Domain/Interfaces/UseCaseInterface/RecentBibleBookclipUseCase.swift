//
//  RecentBibleBookclipUseCase.swift
//  DomainInterface
//
//  Created by 양승현 on 3/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol RecentBibleBookclipUseCase {
  /// 1~ 100%중 몇 퍼센트! 인지 나타냄 e.g. 23.5 == 23.5퍼센트라는것
  typealias RecentlyReadChapterPercentage = CGFloat
  
  func saveRecentClip(_ clip: RecentBibleClip)
  
  func fetchRecentClip() -> RecentBibleClip
  
  /// 1~ 100%중 몇 퍼센트! 인지 나타냄 e.g. 23.5 == 23.5퍼센트라는것
  func calculateRecentBibleReadBookChapterPercentage() -> RecentlyReadChapterPercentage
  
  /// 최근 본 구절의 +- 2구절 총 3구절 verseRange
  func estimatedVisibleVerses(
    _ recentBibleClip: RecentBibleClip,
    completion: @escaping (Result<[BibleVerse], Error>) -> Void)
}
