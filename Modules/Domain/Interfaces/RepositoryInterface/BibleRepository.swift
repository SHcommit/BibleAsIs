//
//  BibleRepository.swift
//  DataInterface
//
//  Created by 양승현 on 2/15/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import DomainEntity
import Foundation

public protocol BibleRepository {
  func fetchBibleVerses(
    for book: BibleBook,
    chapter: Int,
    completion: @escaping (Result<[BibleVerse], Error>) -> Void)
  
  func fetchBibleVerse(
    for book: BibleBook,
    chapter: Int,
    verse: Int,
    completion: @escaping (Result<BibleVerse?, Error>) -> Void)
  
  func fetchBibleVerses(
    forReferences refs: [BibleReference],
    completion: @escaping (Result<[BibleVerse], Error>) -> Void)

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
  
  func fetchHighlights(
    for verseId: Int,
    completion: @escaping (Result<[BibleHighlight], Error>) -> Void)
  func fetchAllHighlights(completion: @escaping (Result<[[BibleHighlight]], Error>) -> Void)
  
  func fetchHeartStatus(
    for verseId: Int,
    completion: @escaping (Result<Bool, Error>) -> Void)
  func fetchAllHearts(completion: @escaping (Result<[BibleHeart], Error>) -> Void)
  
  func hasNotes(for verseId: Int, completion: @escaping (Result<Bool, Error>) -> Void)
  
  /// verseId로 토글함. isOnHeart true면 insert, isOnHeart false면 delete query 로 디비 연산함
  func toggleHeartStatus(for verseId: Int, isOnHeart: Bool, completion: @escaping (Result<Void, Error>) -> Void)
  
  func addHighlight(
    verseId: Int,
    range: NSRange,
    colorIndex: Int,
    completion: @escaping (Result<Int?, Error>) -> Void)
  
  func addNote(
    verseId: Int,
    text: String,
    range: NSRange,
    completion: @escaping (Result<Int?, Error>) -> Void)
  
  func deleteHighlight(_ id: Int, completion: @escaping (Result<Void, Error>) -> Void)
  
  func deleteNote(_ noteId: Int, completion: @escaping (Result<Void, Error>) -> Void)
  
  func deleteHeart(byHeartId heartId: Int, completion: @escaping (Result<Void, Error>) -> Void)
  
  // MARK: - for search history
  func addBibleSearchHistory(
    bibleRef ref: BibleReference,
    completion: @escaping (Result<Void, any Error>) -> Void
  )
  
  /// 1차원 배열은 yyyy-MM-dd 같은거
  /// 일단 페이징 지원 x
  func fetchAllGroupedSearchHistory(
    completion: @escaping (Result<[[BibleSearchHistory]], any Error>) -> Void
  )
  
  func deleteBibleSearchHistories(
    forYear year: String,
    month: String,
    day: String,
    completion: @escaping (Result<Void, any Error>) -> Void
  )
}
