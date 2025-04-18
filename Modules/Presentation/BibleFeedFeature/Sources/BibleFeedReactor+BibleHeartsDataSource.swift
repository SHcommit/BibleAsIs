//
//  BibleFeedReactor+BibleHeartsDataSource.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 3/21/25.
//

import Foundation
import DomainEntity

extension BibleFeedReactor: BibleFeedAdapterBibleHeartsDataSource {
  public var isHeartEmpty: Bool {
    currentState.bibleHeartVerses.isEmpty
  }
  
  public func fetchBibleHeartVerse(indexPath: IndexPath) -> BibleVerse? {
    let index = indexPath.row
    if indexPath.row >= currentState.bibleHeartVerses.count {
      assertionFailure("이거 확인바람 값이 클수가 없는건데 반환할때 로직 자세히 봐바")
      return nil
    }
    return currentState.bibleHeartVerses[index]
  }
  
  public func bibleHeartHeaderItem() -> String? {
    "좋아하는 성경 구절"
  }
}
