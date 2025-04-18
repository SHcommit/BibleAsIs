//
//  DefaultRecentBibleBookclipRepository.swift
//  Data
//
//  Created by 양승현 on 3/15/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Common
import Foundation
import DomainEntity
import CoreInterface
import DomainInterface

/// 백그라운드 사용 안함.
public final class DefaultRecentBibleBookclipRepository: RecentBibleBookclipRepository {
  // MARK: - Properties
  private let userStorage: UserStorageProtocol
  private let storageKey = UserDefaultsKeys.recentBibleClip.rawValue
  
  // MARK: - Lifecycle
  public init(userStorage: UserStorageProtocol) {
    self.userStorage = userStorage
  }
  
  public func saveRecentClip(_ clip: RecentBibleClip) {
    userStorage.save(clip, forKey: storageKey)
  }
  
  public func fetchRecentClip() -> RecentBibleClip {
    let loaded = userStorage.load(forKey: storageKey, type: RecentBibleClip.self)
    if let loaded {
      return loaded
    }
    
    // 사용자가 처음 들어올 경우에만 호출됨
    let baseClip = RecentBibleClip(testament: .old, book: .genesis, chapter: 1, offsetY: 0.0, contentSizeHeight: 0, visibleSizeHeight: 0)
    saveRecentClip(baseClip)
    return baseClip
  }
}
