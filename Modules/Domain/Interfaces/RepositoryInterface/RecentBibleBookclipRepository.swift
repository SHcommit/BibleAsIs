//
//  RecentBibleBookclipRepository.swift
//  DomainEntity
//
//  Created by 양승현 on 3/15/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol RecentBibleBookclipRepository {
  func fetchRecentClip() -> RecentBibleClip
  func saveRecentClip(_ clip: RecentBibleClip)
}
