//
//  Book+Code.swift
//  DomainEntity
//
//  Created by 양승현 on 2/27/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

extension BibleBook {
  // MARK: - 디비 저장된 bible code
  public var code: String {
    switch self {
    case .genesis: return "01"
    case .exodus: return "02"
    case .leviticus: return "03"
    case .numbers: return "04"
    case .deuteronomy: return "05"
    case .joshua: return "06"
    case .judges: return "07"
    case .ruth: return "08"
    case .firstSamuel: return "09"
    case .secondSamuel: return "10"
    case .firstKings: return "11"
    case .secondKings: return "12"
    case .firstChronicles: return "13"
    case .secondChronicles: return "14"
    case .ezra: return "15"
    case .nehemiah: return "16"
    case .esther: return "17"
    case .job: return "18"
    case .psalms: return "19"
    case .proverbs: return "20"
    case .ecclesiastes: return "21"
    case .songOfSongs: return "22"
    case .isaiah: return "23"
    case .jeremiah: return "24"
    case .lamentations: return "25"
    case .ezekiel: return "26"
    case .daniel: return "27"
    case .hosea: return "28"
    case .joel: return "29"
    case .amos: return "30"
    case .obadiah: return "31"
    case .jonah: return "32"
    case .micah: return "33"
    case .nahum: return "34"
    case .habakkuk: return "35"
    case .zephaniah: return "36"
    case .haggai: return "37"
    case .zechariah: return "38"
    case .malachi: return "39"
    case .matthew: return "40"
    case .mark: return "41"
    case .luke: return "42"
    case .john: return "43"
    case .acts: return "44"
    case .romans: return "45"
    case .firstCorinthians: return "46"
    case .secondCorinthians: return "47"
    case .galatians: return "48"
    case .ephesians: return "49"
    case .philippians: return "50"
    case .colossians: return "51"
    case .firstThessalonians: return "52"
    case .secondThessalonians: return "53"
    case .firstTimothy: return "54"
    case .secondTimothy: return "55"
    case .titus: return "56"
    case .philemon: return "57"
    case .hebrews: return "58"
    case .james: return "59"
    case .firstPeter: return "60"
    case .secondPeter: return "61"
    case .firstJohn: return "62"
    case .secondJohn: return "63"
    case .thirdJohn: return "64"
    case .jude: return "65"
    case .revelation: return "66"
    }
  }
}
