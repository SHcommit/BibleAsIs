//
//  TextHasher.swift
//  Core
//
//  Created by 양승현 on 3/9/25.
//

import Foundation
import CommonCrypto
import CoreInterface

/// 문자열은 40자리 해쉬로  SHA-1 씀
public final class TextHasher: TextHashable {
  private init() { }
  public static let shared = TextHasher()
  
  public func toHash(of text: String) -> String {
    guard let data = text.data(using: .utf8) else { return "" }
    
    var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
    data.withUnsafeBytes { buffer in
      _ = CC_SHA1(buffer.baseAddress, CC_LONG(data.count), &digest)
    }
    
    return digest.map { String(format: "%02x", $0) }.joined()
  }
  
  public func compare(lhs: String, rhs: String) -> Bool {
    return lhs == rhs
  }
}
