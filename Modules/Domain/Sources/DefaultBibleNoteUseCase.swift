//
//  DefaultBibleNoteUseCase.swift
//  Domain
//
//  Created by 양승현 on 3/7/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import DomainInterface

public final class DefaultBibleNoteUseCase: BibleNoteUseCase {
  // MARK: - Properties
  private let bibleRepository: BibleRepository
  
  // MARK: - Lifecycle
  public init(bibleRepository: BibleRepository) {
    self.bibleRepository = bibleRepository
  }
  
  // MARK: - Helpers
  public func fetchNotes(
    for verseId: Int,
    page: Int, pageSize: Int,
    completion: @escaping (Result<(notes: [BibleNote], totalNotes: Int), any Error>) -> Void) {
    bibleRepository.fetchNotes(for: verseId, page: page, pageSize: pageSize, completion: completion)
  }
  
  public func fetchNotes(
    page: Int, pageSize: Int,
    completion: @escaping (Result<(notes: [DomainEntity.BibleNote], totalNotes: Int), any Error>) -> Void
  ) {
    bibleRepository.fetchNotes(page: page, pageSize: pageSize, completion: completion)
  }
  
  public func updateNote(
    _ note: BibleNote,
    completion: @escaping (Result<Bool, Error>) -> Void
  ) {
    bibleRepository.updateNote(note, completion: completion)
  }
  
  public func hasNotes(
    for verseId: Int,
    completion: @escaping (Result<Bool, any Error>) -> Void
  ) {
    bibleRepository.hasNotes(for: verseId, completion: completion)
  }
  
  public func addNote(
    verseId: Int,
    text: String,
    range: NSRange,
    completion: @escaping (Result<Int?, any Error>) -> Void
  ) {
    bibleRepository.addNote(verseId: verseId, text: text, range: range, completion: completion)
  }
  
  public func deleteNote(_ noteId: Int, completion: @escaping (Result<Void, any Error>) -> Void) {
    bibleRepository.deleteNote(noteId, completion: completion)
  }
}
