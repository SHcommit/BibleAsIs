//
//  BibleFeedReactor+BibleReadingGardenViewDataSource.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 3/18/25.
//

import Foundation
import DesignSystemItems
import DomainEntity
import DesignSystemInterface

extension BibleFeedReactor: BibleReadingGardenViewDataSource {
  public var numberOfItems: Int {
    Month.allCases.count
  }
  
  public func item(_ indexPath: IndexPath) -> BibleGardenItem {
    currentState.bibleReadingGardenItems[indexPath.item]
  }
}

extension BibleFeedReactor: BibleFeedAdapterGardenDataSource {
  public func configureGardenCell() -> (any BibleReadingGardenViewDataSource)? {
    self
  }
  
  /// 사용자는 직접 BibleGarden 연도를 지정할 수 있다.
  /// 그러기에 현재 연도가 아닌, 사용자가 선택한 연도를 보여주어야 한다.
  public func gardenHeaderItem() -> Year {
//    currentState.currentYearForBibleGarden
    currentState.selectionYearForBibleGarden
  }
}
