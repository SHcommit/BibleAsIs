//
//  File.swift
//  Common
//
//  Created by 양승현 on 4/3/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

#if canImport(XCTest)
import XCTest

open class BaseXCTestCase: XCTestCase {
  public func waitUntil(timeout: TimeInterval = 7.0, _ task: (@escaping () -> Void) -> Void) {
    let expectation = XCTestExpectation.init(description: "테스트 시작!!!!!")
    task {
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: timeout)
  }
}
#endif
