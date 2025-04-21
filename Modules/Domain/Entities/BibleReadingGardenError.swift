//
//  BibleReadingGardenError.swift
//  DomainEntity
//
//  Created by 양승현 on 3/14/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public enum BibleReadingGardenError: LocalizedError {
  /// 값 저장하려하지만, 이미 중복되어있음
  case hasAlreadyDuplicated
  
  /// 값 삭제하려하지만 이미 존재하지 않는 데이터임
  case hasAlreadyInvalidEntry
  
  public var errorDescription: String? {
    switch self {
    case .hasAlreadyDuplicated:
      "오늘 이 장은 이미 기록되었어요!"
    case .hasAlreadyInvalidEntry:
      "이미 존재하지 않는 값입니다"
    }
  }
}

extension Error {
  public var hasAlreadyDuplicatedErrorInBibleReadingGarden: Bool {
    if let duplidatedErr = self as? BibleReadingGardenError {
      return duplidatedErr == .hasAlreadyDuplicated
    }
    return false
  }
  
  public var hasAlreadyInvalidEntryErrorInBibleReadingGarden: Bool {
    if let duplidatedErr = self as? BibleReadingGardenError {
      return duplidatedErr == .hasAlreadyDuplicated
    }
    return false
  }
}
