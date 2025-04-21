//
//  BibleReadingAnalyzable.swift
//  CoreInterface
//
//  Created by 양승현 on 2/3/25.
//

import Foundation
import DomainEntity

public protocol BibleReadingAnalyzable {
  func makeBibleGardenHitmap(
    for year: Int,
    month: Int,
    byReadingGardens readingGardens: [BibleDailyReadingEntry]
  ) -> [[BibleGardenLevel]]
}
