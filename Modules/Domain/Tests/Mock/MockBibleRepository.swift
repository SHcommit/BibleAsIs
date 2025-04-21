//
//  MockBibleRepository.swift
//  DomainTests
//
//  Created by 양승현 on 3/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import DomainInterface

final class MockBibleRepository: BibleRepository {
  var mockVerses: [BibleVerse] = []
  func fetchBibleVerses(
    for book: DomainEntity.BibleBook, chapter: Int,
    completion: @escaping (Result<[DomainEntity.BibleVerse], any Error>) -> Void) {
      completion(.success(mockVerses))
    }
  
  func fetchBibleVerse(
    for book: DomainEntity.BibleBook, chapter: Int, verse: Int,
    completion: @escaping (Result<DomainEntity.BibleVerse?, any Error>) -> Void) { }
  
  func fetchNotes(
    for verseId: Int, page: Int, pageSize: Int,
    completion: @escaping (Result<(notes: [DomainEntity.BibleNote], totalNotes: Int), any Error>) -> Void) { }
  
  func fetchNotes(
    page: Int, pageSize: Int,
    completion: @escaping (Result<(notes: [DomainEntity.BibleNote], totalNotes: Int), any Error>) -> Void
  ) { }
  
  func updateNote(
    _ note: DomainEntity.BibleNote, completion: @escaping (Result<Bool, any Error>) -> Void) { }
  
  func fetchHighlights(
    for verseId: Int, completion: @escaping (Result<[DomainEntity.BibleHighlight], any Error>) -> Void) { }
  
  func fetchAllHighlights(completion: @escaping (Result<[[DomainEntity.BibleHighlight]], any Error>) -> Void) { }
  
  func fetchHeartStatus(for verseId: Int, completion: @escaping (Result<Bool, any Error>) -> Void) { }
  
  func fetchAllHearts(completion: @escaping (Result<[DomainEntity.BibleHeart], any Error>) -> Void) { }
  
  func hasNotes(for verseId: Int, completion: @escaping (Result<Bool, any Error>) -> Void) { }
  
  func toggleHeartStatus(
    for verseId: Int, isOnHeart: Bool, completion: @escaping (Result<Void, any Error>) -> Void) { }
  
  func addHighlight(
    verseId: Int, range: NSRange, colorIndex: Int, completion: @escaping (Result<Int?, any Error>) -> Void) { }
  
  func addNote(
    verseId: Int, text: String, range: NSRange, completion: @escaping (Result<Int?, any Error>) -> Void) { }
  
  func deleteHighlight(_ id: Int, completion: @escaping (Result<Void, any Error>) -> Void) { }
  
  func deleteNote(_ noteId: Int, completion: @escaping (Result<Void, any Error>) -> Void) { }
  
  func deleteHeart(byHeartId heartId: Int, completion: @escaping (Result<Void, any Error>) -> Void) { }
  
  func addBibleSearchHistory(
    bibleRef ref: DomainEntity.BibleReference, completion: @escaping (Result<Void, any Error>) -> Void) { }
  
  func fetchAllGroupedSearchHistory(
    completion: @escaping (Result<[[DomainEntity.BibleSearchHistory]], any Error>) -> Void) { }
  
  func deleteBibleSearchHistories(
    forYear year: String, month: String, day: String, completion: @escaping (Result<Void, any Error>) -> Void) { }
  
  func fetchBibleVerses(
    forReferences refs: [BibleReference],
    completion: @escaping (Result<[BibleVerse], Error>) -> Void
  ) {
    let mockedVerses = refs.map { reference in
      BibleVerse(book: reference.book, chapter: reference.chapter, verse: reference.verse, content: "Mocked Content \(reference.verse)")
    }
    completion(.success(mockedVerses))
  }
}

final class MockDailyBibleRandomVerseFetchRepository: DailyBibleRandomVerseFetchRepository {
  func fetchRandomVerse(day: Int) -> [DailyRandomVerseEntity] {
    return [
      DailyRandomVerseEntity(day: 1, book: .firstChronicles, chapter: 29, verse: 11),
      DailyRandomVerseEntity(day: 1, book: .firstChronicles, chapter: 29, verse: 12)
    ]
  }
  
  func fetchWeeklyRandomVerses(fromDay: Int) -> [[DailyRandomVerseEntity]] {
    return [
      [DailyRandomVerseEntity(day: 1, book: .firstChronicles, chapter: 29, verse: 11),
       DailyRandomVerseEntity(day: 1, book: .firstChronicles, chapter: 29, verse: 12)],
      [DailyRandomVerseEntity(day: 2, book: .daniel, chapter: 4, verse: 34),
       DailyRandomVerseEntity(day: 2, book: .daniel, chapter: 4, verse: 35)],
      [DailyRandomVerseEntity(day: 3, book: .psalms, chapter: 22, verse: 27),
       DailyRandomVerseEntity(day: 3, book: .psalms, chapter: 22, verse: 28)],
      [DailyRandomVerseEntity(day: 4, book: .psalms, chapter: 115, verse: 3),
       DailyRandomVerseEntity(day: 4, book: .psalms, chapter: 115, verse: 4)],
      [DailyRandomVerseEntity(day: 5, book: .firstTimothy, chapter: 6, verse: 15),
       DailyRandomVerseEntity(day: 5, book: .firstTimothy, chapter: 6, verse: 16)],
      [DailyRandomVerseEntity(day: 6, book: .isaiah, chapter: 45, verse: 5),
       DailyRandomVerseEntity(day: 6, book: .isaiah, chapter: 45, verse: 6),
       DailyRandomVerseEntity(day: 6, book: .isaiah, chapter: 45, verse: 7)],
      [DailyRandomVerseEntity(day: 7, book: .romans, chapter: 9, verse: 15),
       DailyRandomVerseEntity(day: 7, book: .romans, chapter: 9, verse: 16)]
    ]
  }
}
