//
//  BibleReadingGardenFetchUseCase.swift
//  DomainInterface
//
//  Created by 양승현 on 3/18/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol BibleReadingGardenFetchUseCase {
  /// 저장하기 위해 필요한 것들.
  /// 1. 중복인가?
  /// 오늘 날짜인가?
  func saveBibleReadingGarden(
    for newEntry: BibleReadingGardenLogEntry,
    completion: @escaping (Result<Void, Error>) -> Void)
}
