//
//  BibleStructureCategory.swift
//  DomainEntity
//
//  Created by 양승현 on 3/31/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public enum BibleStructureCategory: CaseIterable {
  /// 율법서
  case oldTestamentLaw
  /// 역사서
  case oldTestamentHistory
  /// 시가서
  case oldTestamentPoetry
  /// 예언서
  case oldTestamentProphecy
  
  /// 복음서
  case newTestamentGospels
  /// 역사서
  case newTestamentHistory
  /// 바울서신
  case newTestamentPaulineEpistles
  /// 일반서신
  case newTestamentGeneralEpistles
  /// 예언서
  case newTestamentProphecy
  
  /// 카테고리 별 총 챕터 개수임당
  public var totalChapters: Int {
    return BibleBook.allBooks
      .filter { $0.category == self }
      .map { $0.numberOfChapters }
      .reduce(0, +)
  }
}

extension BibleBook {
  public var category: BibleStructureCategory {
    switch self {
    case .genesis, .exodus, .leviticus, .numbers, .deuteronomy:
      return .oldTestamentLaw
    case .joshua, .judges, .ruth, .firstSamuel, .secondSamuel, .firstKings, .secondKings,
        .firstChronicles, .secondChronicles, .ezra, .nehemiah, .esther:
      return .oldTestamentHistory
    case .job, .psalms, .proverbs, .ecclesiastes, .songOfSongs:
      return .oldTestamentPoetry
    case .isaiah, .jeremiah, .lamentations, .ezekiel, .daniel, .hosea, .joel,
        .amos, .obadiah, .jonah, .micah, .nahum, .habakkuk, .zephaniah, .haggai, .zechariah, .malachi:
      return .oldTestamentProphecy
    case .matthew, .mark, .luke, .john:
      return .newTestamentGospels
    case .acts:
      return .newTestamentHistory
    case .romans, .firstCorinthians, .secondCorinthians, .galatians, .ephesians, .philippians, .colossians,
        .firstThessalonians, .secondThessalonians, .firstTimothy, .secondTimothy, .titus, .philemon, .hebrews:
      return .newTestamentPaulineEpistles
    case .james, .firstPeter, .secondPeter, .firstJohn, .secondJohn, .thirdJohn, .jude:
      return .newTestamentGeneralEpistles
    case .revelation:
      return .newTestamentProphecy
    }
  }
}
