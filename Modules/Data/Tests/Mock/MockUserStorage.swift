//
//  MockUserStorage.swift
//  Data
//
//  Created by 양승현 on 3/3/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import CoreInterface

final class MockUserStorage: UserStorageProtocol {
  private var storage: [String: Data] = [:]
  
  func load<T: Decodable>(forKey key: String, type: T.Type) -> T? {
    guard let data = storage[key],
          let decoded = try? JSONDecoder().decode(T.self, from: data) else {
      return nil
    }
    return decoded
  }
  
  func save<T: Encodable>(_ value: T, forKey key: String) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(value) {
      storage[key] = encoded
    }
  }
  
  func delete(forKey key: String) {}
}
