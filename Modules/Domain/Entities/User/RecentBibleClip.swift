//
//  RecentBibleClip.swift
//  Entity
//
//  Created by 양승현 on 2/13/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

/// 최근 바이블을 읽은 데이터를 담습니다.
public struct RecentBibleClip: Equatable, PrettyDebugStringConvertible {
  public var testament: BibleTestament
  public var book: BibleBook
  public var chapter: Int
  
  public var offsetY: CGFloat
  /// 사용자가 글자 크기 변경 할 때마다 매번 바뀝니다
  public var contentSizeHeight: CGFloat
  
  /// offsetY, contentSizeHeight, visibleSizeHeight 이 3개를 가지고 대략적인 몇 퍼센트 읽었는지 가늠할수있는데 정확하지 않아요.
  public var visibleSizeHeight: CGFloat
  
  public init(
    testament: BibleTestament,
    book: BibleBook,
    chapter: Int,
    offsetY: CGFloat,
    contentSizeHeight: CGFloat,
    visibleSizeHeight: CGFloat
  ) {
    self.testament = testament
    self.book = book
    self.chapter = chapter
    self.offsetY = offsetY
    self.contentSizeHeight = contentSizeHeight
    self.visibleSizeHeight = visibleSizeHeight
  }
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    (lhs.book == rhs.book && lhs.chapter == rhs.chapter &&
     lhs.testament == rhs.testament && lhs.contentSizeHeight == rhs.contentSizeHeight &&
     lhs.visibleSizeHeight == rhs.visibleSizeHeight && lhs.offsetY == rhs.offsetY)
  }
}

extension RecentBibleClip: Codable {
  enum CodingKeys: String, CodingKey {
    case testament
    case book
    case chapter
    
    case offsetY
    case contentSizeHeight
    case visibleSizeHeight
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(testament.name, forKey: .testament)
    try container.encode(book.name, forKey: .book)
    try container.encode(chapter, forKey: .chapter)
    try container.encode(offsetY, forKey: .offsetY)
    try container.encode(contentSizeHeight, forKey: .contentSizeHeight)
    try container.encode(visibleSizeHeight, forKey: .visibleSizeHeight)
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let testamentName = try container.decode(String.self, forKey: .testament)
    let bookName = try container.decode(String.self, forKey: .book)
    let chapter = try container.decode(Int.self, forKey: .chapter)
    let offsetY = try container.decode(CGFloat.self, forKey: .offsetY)
    let contentSizeHeight = try container.decode(CGFloat.self, forKey: .contentSizeHeight)
    let visibleSizeHeight = try container.decode(CGFloat.self, forKey: .visibleSizeHeight)
    
    guard let testament = BibleTestament(name: testamentName) else {
      throw DecodingError.dataCorruptedError(forKey: .testament, in: container, debugDescription: "Invalid testament name")
    }
    
    guard let book = BibleBook(name: bookName) else {
      throw DecodingError.dataCorruptedError(
        forKey: .book, in: container, debugDescription: "Invalid book name")
    }
    
    self.testament = testament
    self.book = book
    self.chapter = chapter
    self.offsetY = offsetY
    self.contentSizeHeight = contentSizeHeight
    self.visibleSizeHeight = visibleSizeHeight
  }
}
