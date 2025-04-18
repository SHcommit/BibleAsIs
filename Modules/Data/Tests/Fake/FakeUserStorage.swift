//
//  FakeUserStorage.swift
//  DataTests
//
//  Created by 양승현 on 2/24/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import CoreInterface

final class FakeUserStorage: UserStorageProtocol {
  var storage = [String: Data]()
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  
  func save<T: Codable>(_ value: T, forKey key: String) {
    if let data = try? encoder.encode(value) {
      storage[key] = data
    }
  }
  
  func load<T: Codable>(forKey key: String, type: T.Type) -> T? {
    guard let data = storage[key] else { return nil }
    return try? decoder.decode(type, from: data)
  }
  
  func delete(forKey key: String) {
    storage.removeValue(forKey: key)
  }
}
