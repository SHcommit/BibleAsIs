//
//  SleepTimeHandleRepository.swift
//  DomainInterface
//
//  Created by 양승현 on 3/16/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol SleepTimeHandleRepository {
  func saveUserPickSleepTime(_ entry: SleepTimeEntry)
  func fetchUserPickSleepTime() -> SleepTimeEntry?
}
