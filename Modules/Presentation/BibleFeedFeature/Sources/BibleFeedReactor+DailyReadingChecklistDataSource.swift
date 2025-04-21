//
//  BibleFeedReactor+DailyReadingChecklistDataSource.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 3/19/25.
//

import RxSwift
import ReactorKit
import Foundation
import DesignSystemItems

extension BibleFeedReactor: BibleFeedAdapterDailyReadingChecklistDataSource {
  public func dailyReadingChecklistCardItem() -> DailyBibleReadingChecklistCardItem {
    guard let item = currentState.dailyReadingChecklistCardItem else {
      return .init(isExecutingState: false, currentReadingPercentage: 0.0)
    }
    return item
  }
  
  public func dailyReadingChecklistDescriptionItem() -> BibleDailyReadingPlanDescriptionItem {
    currentState.dailyReadingChecklistDescriptionItem
  }
  
  public func dailyReadingChecklistHeaderItem() -> String? {
    "일독 챌린지"
  }
}
