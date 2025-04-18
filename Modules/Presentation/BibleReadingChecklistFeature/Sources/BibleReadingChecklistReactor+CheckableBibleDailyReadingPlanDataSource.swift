//
//  BibleReadingChecklistReactor+CheckableBibleDailyReadingPlanDataSource.swift
//  BibleReadingChecklistFeature
//
//  Created by 양승현 on 3/23/25.
//

import Foundation
import DomainEntity
import DesignSystemItems
import DesignSystemInterface

// MARK: - CheckableBibleDailyReadingPlanDataSource
extension BibleReadingChecklistReactor: CheckableBibleDailyReadingPlanDataSource {
  public var hasInitiallyFetched: Bool {
    currentState.hasInitiallyFetched
  }
  
  public var isDailyReadingPlanExecutingState: Bool {
    currentState.descriptionItem.startDateStr != ""
  }
  
  public var totalCurrentReadingPercentage: CGFloat {
    let r = Double(currentState.descriptionItem.totalReadChapters) / Double(BibleBook.allChapters) * 100.0
    return r > 100.0 ? 100.0 : r
  }
  
  public var descriptionItem: BibleDailyReadingPlanDescriptionItem {
    currentState.descriptionItem
  }
  
  public func dailyReadingItem(row: Int) -> CheckableBibleDailyReadingItem {
    return currentState.checkableBibleDailyReadingItems[row]
  }
  
  public func isOldTestament(forIndexPath: IndexPath) -> Bool {
    return currentState.checkableBibleDailyReadingItems[forIndexPath.row].book.isOldTestament
  }
}
