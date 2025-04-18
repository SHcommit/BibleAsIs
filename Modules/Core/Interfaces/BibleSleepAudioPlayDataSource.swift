//
//  BibleSleepAudioPlayDataSource.swift
//  CoreInterface
//
//  Created by 양승현 on 3/16/25.
//

import Foundation
import DomainEntity

public protocol BibleSleepAudioPlayDataSource: AnyObject {
  /// 왜 이게 있어야?.. 정지 됬다 다시 진행하는 경우 때문임
  func fetchCurrentVerse() -> BibleVerse?
  
  func fetchNextVerse() -> BibleVerse?
  // 이전 verse가 없으면 없다는거임.
  func fetchPrevVerse() -> BibleVerse?
}
