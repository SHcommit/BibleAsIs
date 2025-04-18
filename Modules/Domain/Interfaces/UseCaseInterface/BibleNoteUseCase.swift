//
//  BibleNoteUseCase.swift
//  Domain
//
//  Created by 양승현 on 3/7/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol BibleNoteUseCase {
  func fetchNotes(
    for verseId: Int,
    page: Int, pageSize: Int,
    completion: @escaping (Result<(notes: [BibleNote], totalNotes: Int), Error>) -> Void)
  
  func fetchNotes(
    page: Int,
    pageSize: Int,
    completion: @escaping (Result<(notes: [BibleNote], totalNotes: Int), Error>) -> Void)
  
  func updateNote(
    _ note: BibleNote,
    completion: @escaping (Result<Bool, Error>) -> Void)
  
  func hasNotes(for verseId: Int, completion: @escaping (Result<Bool, Error>) -> Void)
  
  func addNote(
    verseId: Int,
    text: String,
    range: NSRange,
    completion: @escaping (Result<Int?, Error>) -> Void)
  
  func deleteNote(_ noteId: Int, completion: @escaping (Result<Void, Error>) -> Void)
}
