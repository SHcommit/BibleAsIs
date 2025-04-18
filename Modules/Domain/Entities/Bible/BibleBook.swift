//
//  BibleBook.swift
//  Entity
//
//  Created by 양승현 on 2/1/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public enum BibleBook: String, Codable, Equatable {
  // MARK: - 구약
  case genesis = "창세기"
  case exodus = "출애굽기"
  case leviticus = "레위기"
  case numbers = "민수기"
  case deuteronomy = "신명기"
  case joshua = "여호수아"
  case judges = "사사기"
  case ruth = "룻기"
  case firstSamuel = "사무엘상"
  case secondSamuel = "사무엘하"
  case firstKings = "열왕기상"
  case secondKings = "열왕기하"
  case firstChronicles = "역대상"
  case secondChronicles = "역대하"
  case ezra = "에스라"
  case nehemiah = "느헤미야"
  case esther = "에스더"
  case job = "욥기"
  case psalms = "시편"
  case proverbs = "잠언"
  case ecclesiastes = "전도서"
  case songOfSongs = "아가"
  case isaiah = "이사야"
  case jeremiah = "예레미야"
  case lamentations = "예레미야 애가"
  case ezekiel = "에스겔"
  case daniel = "다니엘"
  case hosea = "호세아"
  case joel = "요엘"
  case amos = "아모스"
  case obadiah = "오바댜"
  case jonah = "요나"
  case micah = "미가"
  case nahum = "나훔"
  case habakkuk = "하박국"
  case zephaniah = "스바냐"
  case haggai = "학개"
  case zechariah = "스가랴"
  case malachi = "말라기"
  
  // MARK: - 신약
  case matthew = "마태복음"
  case mark = "마가복음"
  case luke = "누가복음"
  case john = "요한복음"
  case acts = "사도행전"
  case romans = "로마서"
  case firstCorinthians = "고린도전서"
  case secondCorinthians = "고린도후서"
  case galatians = "갈라디아서"
  case ephesians = "에베소서"
  case philippians = "빌립보서"
  case colossians = "골로새서"
  case firstThessalonians = "데살로니가전서"
  case secondThessalonians = "데살로니가후서"
  case firstTimothy = "디모데전서"
  case secondTimothy = "디모데후서"
  case titus = "디도서"
  case philemon = "빌레몬서"
  case hebrews = "히브리서"
  case james = "야고보서"
  case firstPeter = "베드로전서"
  case secondPeter = "베드로후서"
  case firstJohn = "요한일서"
  case secondJohn = "요한이서"
  case thirdJohn = "요한삼서"
  case jude = "유다서"
  case revelation = "요한계시록"
  
  public init?(name: String) {
    self.init(rawValue: name)
  }
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.rawValue == rhs.rawValue
  }
}

// MARK: - Helpers
extension BibleBook {
  public var name: String { rawValue }
  
  public var numberOfChapters: Int {
    switch self {
    case .genesis: return 50
    case .exodus: return 40
    case .leviticus: return 27
    case .numbers: return 36
    case .deuteronomy: return 34
    case .joshua: return 24
    case .judges: return 21
    case .ruth: return 4
    case .firstSamuel: return 31
    case .secondSamuel: return 24
    case .firstKings: return 22
    case .secondKings: return 25
    case .firstChronicles: return 29
    case .secondChronicles: return 36
    case .ezra: return 10
    case .nehemiah: return 13
    case .esther: return 10
    case .job: return 42
    case .psalms: return 150
    case .proverbs: return 31
    case .ecclesiastes: return 12
    case .songOfSongs: return 8
    case .isaiah: return 66
    case .jeremiah: return 52
    case .lamentations: return 5
    case .ezekiel: return 48
    case .daniel: return 12
    case .hosea: return 14
    case .joel: return 3
    case .amos: return 9
    case .obadiah: return 1
    case .jonah: return 4
    case .micah: return 7
    case .nahum: return 3
    case .habakkuk: return 3
    case .zephaniah: return 3
    case .haggai: return 2
    case .zechariah: return 14
    case .malachi: return 4
    case .matthew: return 28
    case .mark: return 16
    case .luke: return 24
    case .john: return 21
    case .acts: return 28
    case .romans: return 16
    case .firstCorinthians: return 16
    case .secondCorinthians: return 13
    case .galatians: return 6
    case .ephesians: return 6
    case .philippians: return 4
    case .colossians: return 4
    case .firstThessalonians: return 5
    case .secondThessalonians: return 3
    case .firstTimothy: return 6
    case .secondTimothy: return 4
    case .titus: return 3
    case .philemon: return 1
    case .hebrews: return 13
    case .james: return 5
    case .firstPeter: return 5
    case .secondPeter: return 3
    case .firstJohn: return 5
    case .secondJohn: return 1
    case .thirdJohn: return 1
    case .jude: return 1
    case .revelation: return 22
    }
  }
  
  public static var allChapters: Int {
    Self.allBooks.reduce(0, {$0 + $1.numberOfChapters })
  }
  
  public static var oldTestaments: [Self] {
    [
      .genesis, .exodus, .leviticus, .numbers, .deuteronomy, .joshua, .judges, .ruth,
      .firstSamuel, .secondSamuel, .firstKings, .secondKings, .firstChronicles, .secondChronicles,
      .ezra, .nehemiah, .esther, .job, .psalms, .proverbs, .ecclesiastes, .songOfSongs,
      .isaiah, .jeremiah, .lamentations, .ezekiel, .daniel, .hosea, .joel, .amos, .obadiah,
      .jonah, .micah, .nahum, .habakkuk, .zephaniah, .haggai, .zechariah, .malachi
    ]
  }
  
  public static var newTestaments: [Self] {
    [
      .matthew, .mark, .luke, .john, .acts, .romans, .firstCorinthians, .secondCorinthians,
      .galatians, .ephesians, .philippians, .colossians, .firstThessalonians, .secondThessalonians,
      .firstTimothy, .secondTimothy, .titus, .philemon, .hebrews, .james, .firstPeter, .secondPeter,
      .firstJohn, .secondJohn, .thirdJohn, .jude, .revelation
    ]
  }
  
  public static var allBooks: [Self] {
    return oldTestaments + newTestaments
  }
  
  public var isOldTestament: Bool {
    return Self.oldTestaments.contains(self)
  }
  
  public static var bookOrderDictionary: [Self: Int] {
    return (Self.oldTestaments + Self.newTestaments).enumerated().reduce(into: [Self: Int]()) {
      $0[$1.element] = $1.offset + 1
    }
  }
  
  public var bookOrder: Int {
    return Self.bookOrderDictionary[self] ?? -1
  }
}
