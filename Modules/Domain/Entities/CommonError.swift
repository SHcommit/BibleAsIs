//
//  CommonError.swift
//  Common
//
//  Created by 양승현 on 2/15/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public enum CommonError: Error {
  case unknown
  /// gaurd let self else return 이 경우 에러
  case referenceDeallocated
  
  case noDataFound
}

extension Error {
  public var isReferenceError: Bool {
    if let commonError = self as? CommonError {
      return commonError == .referenceDeallocated
    }
    return false
  }
}

extension CommonError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .unknown:
      return "알 수 없는 오류가 발생했습니다. 다시 시도해주세요."
    case .referenceDeallocated:
      return "예상치 못한 동작이 감지되었습니다. 필요한 객체가 해제되었습니다."
    case .noDataFound:
      return "알 수 없는 오류가 발생해 데이터를 가져올 수 없습니다."
    }
  }
}
