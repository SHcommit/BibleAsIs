//
//  DailyMccCheyneEntity.swift
//  DomainEntity
//
//  Created by 양승현 on 2/26/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public struct BibleMccCheyneReference: PrettyDebugStringConvertible, Equatable {
  public let book: BibleBook
  public let chapter: Int
  /// 읽어야 할 시작 verse (절)
  public let verseStartNumber: Int?
  public let verseEndNumber: Int?
  public var aleadyRead: Bool
  
  public init(book: BibleBook, chapter: Int, verseStartNumber: Int?, verseEndNumber: Int?, aleadyRead: Bool) {
    self.book = book
    self.chapter = chapter
    self.verseStartNumber = verseStartNumber
    self.verseEndNumber = verseEndNumber
    self.aleadyRead = aleadyRead
  }
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    (lhs.book == rhs.book && lhs.aleadyRead == rhs.aleadyRead && lhs.chapter == rhs.chapter
     && lhs.verseStartNumber == rhs.verseStartNumber && lhs.verseEndNumber == rhs.verseEndNumber)
  }
}

/// 하루에 4개의 챌린지를 하지만, numOfChapters는 5개 이상일 수 있다. 즉, references는 5개 이상일 수 있음.
public struct DailyMccCheyneEntity: PrettyDebugStringConvertible, Equatable {
  public let day: Int
  public var references: [BibleMccCheyneReference]
  
  public init(day: Int, references: [BibleMccCheyneReference]) {
    self.day = day
    self.references = references
  }
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.day == rhs.day && lhs.references == rhs.references
  }
}

// MARK: - Helpers
extension DailyMccCheyneEntity {
  public func groupedReferences() -> [BibleBook: [BibleMccCheyneReference]] {
    return Dictionary(grouping: references, by: { $0.book })
  }
  
  public func sortedBookKeys() -> [BibleBook] {
    return groupedReferences().keys.sorted(by: { Int($0.code) ?? 0 < Int($1.code) ?? 0 })
  }
  
  /// Bible module's README.md 기반으로,, 크게 4개 경우에 의해서 변환된 refs를 사용자에게 보여줄 수 있는 챌린지 미션 string으로 만들어야 함.
  /// 내부적으로 refs 원소 자체도 정렬 되야 함. 아마 디비에서 내부적으로 내가 book 을 INTEGER로 캐스팅하고 같으면 챕터까지 작은순으로 반환하라고 query만들긴함,,
  /// 혹 시 모르니 한 번 더 정렬 긔긔
  public func generateChallenges() -> [String] {
    let groupedReferences = groupedReferences()
    var challengeStrings: [String] = []
    
    for (_, refs) in groupedReferences.sorted(by: { Int($0.key.code) ?? 0 < Int($1.key.code) ?? 0 }) {
      if refs.count == 1 {
        let ref = refs.first!
        if let verseStart = ref.verseStartNumber, let verseEnd = ref.verseEndNumber {
          challengeStrings.append("\(ref.book.name) \(ref.chapter):\(verseStart)~\(verseEnd)")
        } else {
          challengeStrings.append("\(ref.book.name) \(ref.chapter)")
        }
      } else {
        let firstRef = refs.first!
        let lastRef = refs.last!
        
        if refs.allSatisfy({ $0.verseStartNumber == nil && $0.verseEndNumber == nil }) {
          if refs.count == 2 {
            challengeStrings.append("\(firstRef.book.name) \(firstRef.chapter) ~ \(lastRef.chapter)")
          } else {
            challengeStrings.append("\(firstRef.book.name) \(firstRef.chapter) ~ \(lastRef.chapter)")
          }
        } else {
          let firstStart = firstRef.verseStartNumber ?? 1
          let lastEnd = lastRef.verseEndNumber ?? 160
          
          challengeStrings.append("\(firstRef.book.name) \(firstRef.chapter):\(firstStart) ~ \(lastRef.chapter):\(lastEnd)")
        }
      }
    }
    
    return challengeStrings
  }
  
  /// key에 대한 배열에 ref가 하나라면, 그 하나만 반환
  /// key(Bible Book)에 대한 refs가 여러개라면 첫번째, 맨마지막 만 반환해서 범위를 표하게 함.
  public func rangeReferences(for book: BibleBook) -> [BibleMccCheyneReference] {
    guard let references = groupedReferences()[book] else { return [] }
    
    if references.count == 1 {
      return references
    } else if references.count >= 2 {
      let sortedRefs = references.sorted(by: { $0.chapter < $1.chapter })
      return [sortedRefs.first!, sortedRefs.last!]
    }
    
    return []
  }
}
