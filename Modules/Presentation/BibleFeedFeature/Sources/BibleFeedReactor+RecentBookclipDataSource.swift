//
//  BibleFeedReactor+RecentBookclipDataSource.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 3/19/25.
//

import Foundation
import DesignSystemItems
import DesignSystemInterface

extension BibleFeedReactor: BibleFeedAdapterRecentBookclipDataSource {
  public func recentBookclipHeaderItem() -> String {
    "최근 본 성경 구절"
  }
  
  public var recentReadBibleBookClipItem: RecentReadBibleBookclipItem {
    if let item = currentState.recentReadBibleBookclipItem {
      return item
    }
    
    /// 맨 처음 사용하는 사용자를 위한! 디폴트 클립 !!
    /// 사용자가 이제 성경 컨텐츠를 한번이라도 읽으면 그거로 클립이 변경됨
    let v1 = "태초에 하나님이 천지를 창조하시니라"
    let v2 = "땅이 혼돈하고 공허하며 흑암이 깊음 위에 있고 하나님의 신은 수면에 운행하시니라"
    let v3 = "하나님이 가라사대 빛이 있으라 하시매 빛이 있었고"
    let recentReadBibleBookclipItem = RecentReadBibleBookclipItem(
      versesContent: v1 + v2 + v3,
      bibleReference: .init(book: .genesis, chapter: 1, verse: 1),
      currentReadPercentage: 1)
    return recentReadBibleBookclipItem
  }
}
