//
//  BibleTestament.swift
//  Entity
//
//  Created by 양승현 on 2/11/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public enum BibleTestament: Int {
  case old = 0
  case new = 1
  
  public var name: String {
    switch self {
    case .old:
      return "구약"
    case .new:
      return "신약"
    }
  }
  
  public init(isOldTestament: Bool) {
    if isOldTestament {
      self = .old
    } else {
      self = .new
    }
  }
  
  public init?(rawValue: Int) {
    if rawValue == 0 {
      self = .old
    } else if rawValue == 1 {
      self = .new
    } else {
      return nil
    }
  }
  
  public init?(name: String) {
    if name == "구약" {
      self = .old
    } else if name == "신약" {
      self = .new
    } else {
      return nil
    }
  }
}
