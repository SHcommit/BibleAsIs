//
//  BibleReadingGardenTrackable.swift
//  DomainInterface
//
//  Created by 양승현 on 3/14/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol BibleReadingGardenTrackable {
  func increaseForTodayReadingChapters()
  func decreaseForTodayReadingChapters()
  func fetchTodayReadingEntry(completion: @escaping (Result<BibleDailyReadingEntry, any Error>) -> Void)
}
