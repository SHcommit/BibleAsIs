//
//  UserStorageProtocol.swift
//  CoreInterface
//
//  Created by 양승현 on 2/13/25.
//

import Foundation

public protocol UserStorageProtocol {
  func save<T: Codable>(_ value: T, forKey key: String)
  func load<T: Codable>(forKey key: String, type: T.Type) -> T?
  func delete(forKey key: String)
}
