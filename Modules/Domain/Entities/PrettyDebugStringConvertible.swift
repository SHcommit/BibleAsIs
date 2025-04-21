//
//  PrettyDebugStringConvertible.swift
//  DomainEntity
//
//  Created by 양승현 on 2/26/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

/// 구조체 프린트 할 때 너무 보기 어려워서 배열이면 들여쓰기, 내부 요소 들여쓰기 등등 추가.
public protocol PrettyDebugStringConvertible: CustomStringConvertible { }

extension PrettyDebugStringConvertible {
  public var description: String {
    return debugDescription(indentLevel: 0)
  }
  
  private func debugDescription(indentLevel: Int) -> String {
    let mirror = Mirror(reflecting: self)
    /// 현재 depth 들여쓰기
    let indent = String(repeating: "  ", count: indentLevel)
    /// 내부 요소 들여쓰기
    let nextIndent = String(repeating: "  ", count: indentLevel + 1)
    /// 배열 요소 들여쓰기
    let deeperIndent = String(repeating: "  ", count: indentLevel + 2)
    
    var str = "\(mirror.subjectType)(\n"
    var first = true
    
    for (label, value) in mirror.children {
      if let label = label {
        if first {
          first = false
        } else {
          str += ",\n"
        }
        
        str += "\(nextIndent)\(label): "
        
        /// 배열 줄 바꾸긔
        if let array = value as? [Any], !array.isEmpty {
          str += "[\n"
          str += array.map {
            if let reflectedValue = $0 as? PrettyDebugStringConvertible {
              return "\(deeperIndent)\(reflectedValue.debugDescription(indentLevel: indentLevel + 2))"
            } else {
              return "\(deeperIndent)\($0)"
            }
          }.joined(separator: ",\n")
          str += "\n\(nextIndent)]"
        } else if let reflectedValue = value as? PrettyDebugStringConvertible {
          str += reflectedValue.debugDescription(indentLevel: indentLevel + 1)
        }
        /// 일반 값
        else {
          str += "\(value)"
        }
      }
    }
    
    str += "\n\(indent))"
    return str
  }
}
