//
//  DefaultBibleRepository.swift
//  DataInterface
//
//  Created by 양승현 on 2/15/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import DomainEntity
import Foundation
import BibleInterface
import DomainInterface

public final class DefaultBibleRepository: BibleRepository {
  // MARK: - Properties
  private let bibleDAO: BibleDAO
  
  private let backgroundQueue = DispatchQueue(label: "com.bible.bibleRepository.queue", qos: .userInteractive)
  
  public init(bibleDAO: BibleDAO) {
    self.bibleDAO = bibleDAO
  }
  
  // MARK: - Helpers
  public func fetchBibleVerses(
    for book: BibleBook,
    chapter: Int,
    completion: @escaping (Result<[BibleVerse], any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleDAO.fetchBibleVerses(for: book, chapter: chapter) { verses in 
        completion(.success(verses))
      }
    }
  }
  
  public func fetchBibleVerse(
    for book: DomainEntity.BibleBook,
    chapter: Int,
    verse: Int,
    completion: @escaping (Result<DomainEntity.BibleVerse?, any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleDAO.fetchBibleVerse(for: book, chapter: chapter, verse: verse) { verse in
        completion(.success(verse))
      }
    }
  }
  
  public func fetchBibleVerses(
    forReferences refs: [BibleReference],
    completion: @escaping (Result<[BibleVerse], any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleDAO.fetchBibleVerses(forReferences: refs) { verses in
        completion(.success(verses))
      }
    
    }
  }
  
  public func fetchNotes(
    for verseId: Int,
    page: Int, pageSize: Int,
    completion: @escaping (Result<(notes: [BibleNote], totalNotes: Int), any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleDAO.fetchNotes(for: verseId, page: page, pageSize: pageSize) { result in
        completion(.success(result))
      }
    }
  }
  
  public func fetchNotes(
    page: Int,
    pageSize: Int,
    completion: @escaping (Result<(notes: [DomainEntity.BibleNote], totalNotes: Int), any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleDAO.fetchNotes(page: page, pageSize: pageSize) { result in
        completion(.success(result))
      }
    }
  }
  
  public func updateNote(
    _ note: BibleNote,
    completion: @escaping (Result<Bool, any Error>) -> Void) {
      backgroundQueue.async { [weak self] in
        guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
        bibleDAO.updateNote(note) { result in
          completion(.success(result))
        }
      }
  }
  
  public func fetchAllHearts(completion: @escaping (Result<[BibleHeart], any Error>) -> Void) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleDAO.fetchAllHearts { hearts in
        completion(.success(hearts))
      }
    }
  }
  
  public func hasNotes(for verseId: Int, completion: @escaping (Result<Bool, any Error>) -> Void) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleDAO.hasNotes(for: verseId) { hasNote in
        completion(.success(hasNote))
      }
    }
  }
  
  public func fetchHighlights(
    for verseId: Int,
    completion: @escaping (Result<[BibleHighlight], any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleDAO.fetchHighlights(for: verseId) { highlights in
        completion(.success(highlights))
      }
    }
  }
  
  public func fetchAllHighlights(
    completion: @escaping (Result<[[BibleHighlight]], any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleDAO.fetchAllHighlights { highlights in
        completion(.success(highlights))
      }
    }
  }
  
  public func fetchHeartStatus(
    for verseId: Int,
    completion: @escaping (Result<Bool, any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleDAO.fetchHeartStatus(for: verseId) { status in
        completion(.success(status))
      }
    }
  }
  
  public func toggleHeartStatus(
    for verseId: Int,
    isOnHeart: Bool,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleDAO.toggleHeartStatus(for: verseId, isOnHeart: isOnHeart) {
        completion(.success(()))
      }
    }
  }
  
  public func addNote(
    verseId: Int,
    text: String,
    range: NSRange,
    completion: @escaping (Result<Int?, any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleDAO.addNote(verseId: verseId, text: text, range: range) { identifier in
        completion(.success(identifier))
      }
    }
  }

  public func addHighlight(
    verseId: Int,
    range: NSRange,
    colorIndex: Int,
    completion: @escaping (Result<Int?, any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleDAO.addHighlight(verseId: verseId, range: range, colorIndex: colorIndex) { identifier in
        completion(.success(identifier))
      }
    }
  }
    
  // MARK: - Delete
  public func deleteNote(_ noteId: Int, completion: @escaping (Result<Void, any Error>) -> Void) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleDAO.deleteNote(noteId: noteId) {
        completion(.success(()))
      }
    }

  }
  
  public func deleteHighlight(
    _ id: Int,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleDAO.deleteHighlight(highlightId: id) {
        completion(.success(()))
      }
    }
  }
  
  public func deleteHeart(byHeartId heartId: Int, completion: @escaping (Result<Void, any Error>) -> Void) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleDAO.deleteHeart(byId: heartId) {
        completion(.success(()))
      }
    }
  }
}

// MARK: - BibleSearchHistory
extension DefaultBibleRepository {
  public func addBibleSearchHistory(
    bibleRef ref: BibleReference,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleDAO.addBibleSearchHistory(bibleRef: ref, nowDate: Date()) {
        completion(.success(()))
      }
    }
  }
  
  /// 1차원 배열은 yyyy-MM-dd 같은거
  /// 일단 페이징 지원 x
  public func fetchAllGroupedSearchHistory(
    completion: @escaping (Result<[[BibleSearchHistory]], any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleDAO.fetchAllGroupedSearchHistory { histories in
        completion(.success(histories))
      }
    }
  }
  
  public func deleteBibleSearchHistories(
    forYear year: String,
    month: String,
    day: String,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleDAO.deleteBibleSearchHistories(forYear: year, month: month, day: day) {
        completion(.success(()))
      }
    }
  }
}
