//
//  RecentBibleBookclipUseCaseTests.swift
//  DomainInterface
//
//  Created by 양승현 on 3/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import XCTest

@testable import Domain
@testable import DomainInterface
@testable import DomainEntity

final class RecentBibleClipTests: XCTestCase {
  var sut: RecentBibleBookclipUseCase!
  var mockRecentBookclipRepository: MockRecentBookclipRepository!
  var mockBibleRepository: MockBibleRepository!
  
  override func setUp() {
    super.setUp()
    mockRecentBookclipRepository = MockRecentBookclipRepository()
    mockBibleRepository = MockBibleRepository()
    sut = DefaultRecentBibleBookclipUseCase(
      recentBookclipRepository: mockRecentBookclipRepository,
      bibleRepository: mockBibleRepository
    )
  }
  
  override func tearDown() {
    sut = nil
    mockRecentBookclipRepository = nil
    mockBibleRepository = nil
    super.tearDown()
  }
  
  /// 현재까지 몇퍼 진행했는가? 대략
  func test_calculateRecentBibleReadBookChapterPercentage() {
    mockRecentBookclipRepository.recentClip = RecentBibleClip(
      testament: .old,
      book: .joshua,
      chapter: 1,
      offsetY: 500,
      contentSizeHeight: 2000,
      visibleSizeHeight: 600)
    
    let progress = sut.calculateRecentBibleReadBookChapterPercentage()
    XCTAssertEqual(progress, 40, accuracy: 7.0, "읽은 비율 이상한데? 한 30퍼 정도 되야 함.")
    print("calculateRecentBibleReadBookChapterPercentage 성공 \(progress)")
  }
  
  func test_calculateRecentBibleReadBookChapterPercentage2() {
    mockRecentBookclipRepository.recentClip = RecentBibleClip(
      testament: .old,
      book: .joshua,
      chapter: 1,
      offsetY: 1200,
      contentSizeHeight: 2000,
      visibleSizeHeight: 600)

    
    let progress = sut.calculateRecentBibleReadBookChapterPercentage()
    XCTAssertEqual(progress, 70, accuracy: 15.0, "읽은 비율 이상한데? 한 80퍼 언저리 정도 되야 함.")
    print("calculateRecentBibleReadBookChapterPercentage 성공 \(progress)")
  }
  
  /// 구절이 단 하나 있는 경우
  func test_estimatedVisibleVerses_oneVerse() {
    mockBibleRepository.mockVerses = [
      BibleVerse(book: .joshua, chapter: 1, verse: 1, content: "In the beginning...")
    ]
    
    let expectation = self.expectation(description: "Fetch estimated verses for 1-verse chapter")
    
    sut.estimatedVisibleVerses(mockRecentBookclipRepository.fetchRecentClip()) { result in
      switch result {
      case .success(let verses):
        XCTAssertEqual(verses.map { $0.verse }, [1], "📖 1절만 있는 경우, [1]만 반환해야 함")
        print("estimatedVisibleVerses 구절 하나인 경우 \n 반환된 구절: \(verses.map { "\($0.verse)" })")
      case .failure(let error):
        XCTFail("estimatedVisibleVerses 예상된 구절을 가져오지 못함: \(error)")
      }
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 2.0)
  }
  
  /// 구절 두개 인 경우
  func test_estimatedVisibleVerses_twoVerses() {
    mockBibleRepository.mockVerses = [
      BibleVerse(book: .joshua, chapter: 1, verse: 1, content: "aaaa"),
      BibleVerse(book: .joshua, chapter: 1, verse: 2, content: "aaaa")
    ]
    
    let expectation = self.expectation(description: "Fetch estimated verses for 2-verse chapter")
    
    sut.estimatedVisibleVerses(mockRecentBookclipRepository.fetchRecentClip()) { result in
      switch result {
      case .success(let verses):
        XCTAssertEqual(verses.map { $0.verse }, [1, 2], "📖 2절만 있는 경우, [1,2] 반환해야 함")
        print("estimatedVisibleVerse\n 구절 2개일 때 반환된 구절: \(verses.map { "\($0.verse)" })")
      case .failure(let error):
        XCTFail("estimatedVisibleVerses 예상된 구절을 가져오지 못함: \(error)")
      }
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 2.0)
  }
  
  /// offset위치에 따라서 어떻게 반환하는지 다 체크해보자.
  func test_estimatedVisibleVerses_variousOffsets() {
    mockBibleRepository.mockVerses = [
      BibleVerse(book: .joshua, chapter: 1, verse: 1, content: "aaaa"),
      BibleVerse(book: .joshua, chapter: 1, verse: 2, content: "bbbb"),
      BibleVerse(book: .joshua, chapter: 1, verse: 3, content: "aaaa"),
      BibleVerse(book: .joshua, chapter: 1, verse: 4, content: "AAAA"),
      BibleVerse(book: .joshua, chapter: 1, verse: 5, content: "AAAA"),
    ]
    
    let testCases: [(offsetY: CGFloat, expectedVerses: [Int])] = [
      (0, [1, 2]),    /// 시작 부분 (1절만 있으면 +-1절 불가능)
      (500, [1, 2, 3]),  /// 초반
      (1000, [2, 3, 4]), // 중간 1
      (1300, [3, 4, 5]), // 중간 2
      (1500, [4, 5]), /// 마지막 부분
      (2100, [4, 5])  /// 마지막 범위 초과한 경우 -> 이경우는 이제 뭐 사용자가 스크롤 빨리해서 offset이 contentSize와 비슷해졌을때 화면 나가는경우 등 다양한 상황.
    ]
    
    for (offset, expected) in testCases {
      mockRecentBookclipRepository.recentClip = RecentBibleClip(
        testament: .old,
        book: .joshua,
        chapter: 1,
        offsetY: offset,
        contentSizeHeight: 2000,
        visibleSizeHeight: 600
      )
      
      let expectation = self.expectation(description: "Fetch estimated verses for offset \(offset)")
      
      sut.estimatedVisibleVerses(mockRecentBookclipRepository.fetchRecentClip()) { result in
        switch result {
        case .success(let verses):
          XCTAssertEqual(verses.map { $0.verse }, expected, "📖 Offset \(offset): 예상된 구절과 다름")
          print("Offset \(offset) 반환된 구절: \(verses.map { "\($0.verse)" })")
        case .failure(let error):
          XCTFail("Offset \(offset): 예상된 구절을 가져오지 못함: \(error)")
        }
        expectation.fulfill()
      }
      
      wait(for: [expectation], timeout: 2.0)
    }
  }
}
