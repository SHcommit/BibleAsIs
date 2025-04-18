//
//  TextHashable.swift
//  CoreInterface
//
//  Created by 양승현 on 3/23/25.
//

import Foundation

public protocol TextHashable {
  func toHash(of text: String) -> String
  func compare(lhs: String, rhs: String) -> Bool
}
