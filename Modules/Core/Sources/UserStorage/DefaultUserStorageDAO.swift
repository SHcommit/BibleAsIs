//
//  DefaultUserStorageDAO.swift
//  CoreInterface
//
//  Created by 양승현 on 2/13/25.
//

import Foundation
import CoreInterface

public final class DefaultUserStorageDAO: UserStorageProtocol {
  // MARK: - Properties
  private let defaults: UserDefaults
  
  // MARK: - Lifecycle
  public init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }
  
  // MARK: - Helpers
  public func save<T>(_ value: T, forKey key: String) where T: Encodable {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(value) {
      defaults.setValue(encoded, forKey: key)
    }
  }
  
  public func load<T: Decodable>(forKey key: String, type: T.Type) -> T? {
    guard let savedData = defaults.value(forKey: key) as? Data else { return nil }
    let decoder = JSONDecoder()
    return try? decoder.decode(T.self, from: savedData)
  }
  
  public func delete(forKey key: String) {
    defaults.removeObject(forKey: key)
  }
}
