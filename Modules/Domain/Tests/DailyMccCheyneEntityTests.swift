//
//  DailyMccCheyneEntityTests.swift
//  DomainTests
//
//  Created by 양승현 on 2/27/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import XCTest
@testable import DomainEntity

/// 이 테스트는 Bible module's README.md 기반으로,, 정말 변환되는지 검증하는테스트.
/// 이 원소 자체도 사실 정렬되야함. 아마 디비에서 내부적으로 내가 book 을 INTEGER로 캐스팅하고 같으면 챕터까지 작은순으로 반환하라고
/// query만들긴함,,
final class DailyMccCheyneEntityTests: XCTestCase {
  func testCase1_SingleChapterPerBook() {
    let dailyEntity = DailyMccCheyneEntity(
      day: 1,
      references: [
        BibleMccCheyneReference(
          book: .genesis, chapter: 1, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
        BibleMccCheyneReference(
          book: .matthew, chapter: 1, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
        BibleMccCheyneReference(
          book: .ezra, chapter: 1, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
        BibleMccCheyneReference(
          book: .acts, chapter: 1, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
      ])
    
    let challenges = dailyEntity.generateChallenges()
    XCTAssertEqual(challenges, [
      "\(BibleBook.genesis.name) 1",
      "\(BibleBook.ezra.name) 1",
      "\(BibleBook.matthew.name) 1",
      "\(BibleBook.acts.name) 1"])
  }
  
  func test_Case2_MultipleChaptersInOneBook() {
    let dailyEntity = DailyMccCheyneEntity(
      day: 9,
      references: [
        BibleMccCheyneReference(
          book: .genesis, chapter: 9, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
        BibleMccCheyneReference(
          book: .genesis, chapter: 10, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
        BibleMccCheyneReference(
          book: .matthew, chapter: 9, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
        BibleMccCheyneReference(
          book: .ezra, chapter: 9, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
        BibleMccCheyneReference(
          book: .acts, chapter: 9, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false)
      ])
    
    let challenges = dailyEntity.generateChallenges()
    XCTAssertEqual(challenges, [
      "\(BibleBook.genesis.name) 9 ~ 10",
      "\(BibleBook.ezra.name) 9",
      "\(BibleBook.matthew.name) 9",
      "\(BibleBook.acts.name) 9"
    ])
  }
  
  func test_Case3_SpecificVerseRange() {
    let dailyEntity = DailyMccCheyneEntity(
      day: 45, references: [
      BibleMccCheyneReference(
        book: .luke, chapter: 1, verseStartNumber: 1, verseEndNumber: 38, aleadyRead: false),
      BibleMccCheyneReference(
        book: .genesis, chapter: 47, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
      BibleMccCheyneReference(
        book: .job, chapter: 13, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
      BibleMccCheyneReference(
        book: .firstCorinthians, chapter: 1, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
    ])
    
    let challenges = dailyEntity.generateChallenges()
    XCTAssertEqual(challenges, [
      "\(BibleBook.genesis.name) 47",
      "\(BibleBook.job.name) 13",
      "\(BibleBook.luke.name) 1:1~38",
      "\(BibleBook.firstCorinthians.name) 1"])
  }
  
  func test_Case4_MultipleChaptersWithVerseRange() {
    let dailyEntity = DailyMccCheyneEntity(
      day: 59,
      references: [
        BibleMccCheyneReference(
          book: .exodus, chapter: 11, verseStartNumber: 1, verseEndNumber: 12, aleadyRead: false),
        BibleMccCheyneReference(
          book: .exodus, chapter: 12, verseStartNumber: 1, verseEndNumber: 28, aleadyRead: false),
        BibleMccCheyneReference(
          book: .luke, chapter: 14, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
        BibleMccCheyneReference(
          book: .job, chapter: 29, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
        BibleMccCheyneReference(book: .firstCorinthians, chapter: 15, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
      ])
    
    let challenges = dailyEntity.generateChallenges()
    XCTAssertEqual(challenges, [
      "출애굽기 11:1 ~ 12:28",
      "\(BibleBook.job.name) 29",
      "\(BibleBook.luke.name) 14",
      "\(BibleBook.firstCorinthians.name) 15"])
  }
  
  func test_GroupedReferences_ReturnsCorrectDictionary() {
    let dailyEntity = DailyMccCheyneEntity(
      day: 9,
      references: [
        BibleMccCheyneReference(
          book: .genesis, chapter: 9, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
        BibleMccCheyneReference(
          book: .genesis, chapter: 10, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
        BibleMccCheyneReference(
          book: .matthew, chapter: 9, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
        BibleMccCheyneReference(
          book: .ezra, chapter: 9, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
        BibleMccCheyneReference(
          book: .acts, chapter: 9, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false)
      ])

    
    let groupedRefs = dailyEntity.groupedReferences()
    
    XCTAssertEqual(groupedRefs.count, 4)
    XCTAssertEqual(groupedRefs[.genesis]?.count, 2)
    XCTAssertEqual(groupedRefs[.matthew]?.count, 1)
    XCTAssertEqual(groupedRefs[.ezra]?.count, 1)
    XCTAssertEqual(groupedRefs[.acts]?.count, 1)
  }
  
  func test_SortedBookKeys_ReturnsCorrectOrder() {
    let dailyEntity = DailyMccCheyneEntity(
      day: 9,
      references: [
        BibleMccCheyneReference(
          book: .genesis, chapter: 9, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
        BibleMccCheyneReference(
          book: .genesis, chapter: 10, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
        BibleMccCheyneReference(
          book: .matthew, chapter: 9, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
        BibleMccCheyneReference(
          book: .ezra, chapter: 9, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false),
        BibleMccCheyneReference(
          book: .acts, chapter: 9, verseStartNumber: nil, verseEndNumber: nil, aleadyRead: false)
      ])
    
    let sortedKeys = dailyEntity.sortedBookKeys()
    XCTAssertEqual(sortedKeys.map { $0.code }, ["01", "15", "40", "44"])
  }
}
