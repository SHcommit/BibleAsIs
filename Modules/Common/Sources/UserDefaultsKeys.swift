//
//  UserDefaultsKeys.swift
//  Common
//
//  Created by 양승현 on 2/14/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public enum UserDefaultsKeys: String {
  /// 최근 바이블으 읽은 book, chapter를 기록한다.
  /// 이때 Offset 을 통해서 몇 절 까지 읽었는지 대략 유추가 대략 가능하다. 100%정확하지는 않지만, 그래도 .
  case recentBibleClip
  
  /// 사용자가 로그인했던 날짜를 저장한다.
  /// 여러모요 유용하게 쓰일거다 randomVerse를 다시 받아온다거나, 피드 화면에서 전체적으로 유용하게 쓰인다 hitmap 갱신이나 등등
  case lastLoginDate
  
  case userSystemSettings
  case ownerPickSleepTimer
  
  case recentlySearchedBibleQueries
  case mccCheyneCurrentDay
  case dailyBibleReadingProgressEntry
  
  public var forKey: String {
    rawValue
  }
  
  public static var recentlySearchedBibleQueriesKey: String {
    Self.recentlySearchedBibleQueries.forKey
  }
}
