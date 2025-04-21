//
//  SleepTimeEntry.swift
//  DomainEntity
//
//  Created by 양승현 on 3/16/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public struct SleepTimeEntry: Codable {
  public var book: BibleBook
  public var chapter: Int
  public var verse: Int
  public var timerOption: SleepTimerOption
  public var currentDuration: TimeInterval
  public var paused: Bool
  /// 이미 한 번 진행 됨 ( 다 끝남 )
  public var playOnceAlreadyDone: Bool
  
  public init(
    book: BibleBook,
    chapter: Int,
    verse: Int,
    timerOption: SleepTimerOption,
    currentDuration: Double,
    paused: Bool,
    playOnceAlreadyDone: Bool
  ) {
    self.playOnceAlreadyDone = playOnceAlreadyDone
    self.book = book
    self.chapter = chapter
    self.verse = verse
    self.timerOption = timerOption
    self.currentDuration = currentDuration
    self.paused = paused
  }
  
  public enum CodingKeys: String, CodingKey {
    case book, chapter, verse, timerOption, currentDuration, paused, playOnceAlreadyDone
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(book.name, forKey: .book)
    try container.encode(chapter, forKey: .chapter)
    try container.encode(verse, forKey: .verse)
    try container.encode(timerOption.rawValue, forKey: .timerOption)
    try container.encode(currentDuration, forKey: .currentDuration)
    try container.encode(paused, forKey: .paused)
    try container.encode(playOnceAlreadyDone, forKey: .playOnceAlreadyDone)
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let bookName = try container.decode(String.self, forKey: .book)
    let timerRawValue = try container.decode(String.self, forKey: .timerOption)
    self.book = .genesis
    if let _book = BibleBook(name: bookName) {
      self.book = _book
    } else {
      assertionFailure("완전히 이게 바이블 북으로 변환되야함 정확히. decoding전에 확인바람.")
    }
    self.chapter = try container.decode(Int.self, forKey: .chapter)
    self.verse = try container.decode(Int.self, forKey: .verse)
    self.timerOption = SleepTimerOption(rawValue: timerRawValue) ?? .fiveMinutes
    self.currentDuration = try container.decode(Double.self, forKey: .currentDuration)
    self.paused = try container.decode(Bool.self, forKey: .paused)
    self.playOnceAlreadyDone = try container.decode(Bool.self, forKey: .playOnceAlreadyDone)
  }
}
