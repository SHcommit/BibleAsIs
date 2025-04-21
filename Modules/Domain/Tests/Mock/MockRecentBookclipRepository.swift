//
//  MockRecentBookclipRepository.swift
//  DomainTests
//
//  Created by 양승현 on 3/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainInterface
import DomainEntity

final class MockRecentBookclipRepository: RecentBibleBookclipRepository {
  var recentClip: RecentBibleClip = RecentBibleClip(
    testament: .old,
    book: .joshua,
    chapter: 1,
    offsetY: 500,
    contentSizeHeight: 2000,
    visibleSizeHeight: 600
  )
  
  func saveRecentClip(_ clip: DomainEntity.RecentBibleClip) { }
  
  func fetchRecentClip() -> RecentBibleClip {
    return recentClip
  }
}
