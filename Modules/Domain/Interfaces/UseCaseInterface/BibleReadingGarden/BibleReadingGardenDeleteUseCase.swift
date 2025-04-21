//
//  BibleReadingGardenDeleteUseCase.swift
//  DomainEntity
//
//  Created by 양승현 on 3/14/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol BibleReadingGardenDeleteUseCase {
  /// 읽기 취소
  func deleteBibleReadingGarden(
    for entry: BibleReadingGardenLogEntry,
    completion: @escaping (Result<Void, Error>) -> Void)
}
