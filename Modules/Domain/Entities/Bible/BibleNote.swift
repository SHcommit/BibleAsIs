//
//  BibleNote.swift
//  Domain
//
//  Created by 양승현 on 1/30/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public struct BibleNote: PrettyDebugStringConvertible {
  public let noteId: Int
  public let verseId: Int
  public var text: String
  public var range: NSRange
  public var date: Date
  
  public init(noteId: Int, verseId: Int, text: String, range: NSRange, date: Date) {
    self.noteId = noteId
    self.verseId = verseId
    self.text = text
    self.range = range
    self.date = date
  }
}
