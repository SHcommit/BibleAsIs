//
//  BibleBook+.swift
//  Common
//
//  Created by 양승현 on 3/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

extension BibleBook {
  
  // MARK: - 이게 필수야 필수!!!!!!! 디비에서 꺼내올때는
  // swiftlint:disable cyclomatic_complexity
  // swiftlint:disable function_body_length
  public init?(code: String) {
    switch code {
    case "01": self = .genesis
    case "02": self = .exodus
    case "03": self = .leviticus
    case "04": self = .numbers
    case "05": self = .deuteronomy
    case "06": self = .joshua
    case "07": self = .judges
    case "08": self = .ruth
    case "09": self = .firstSamuel
    case "10": self = .secondSamuel
    case "11": self = .firstKings
    case "12": self = .secondKings
    case "13": self = .firstChronicles
    case "14": self = .secondChronicles
    case "15": self = .ezra
    case "16": self = .nehemiah
    case "17": self = .esther
    case "18": self = .job
    case "19": self = .psalms
    case "20": self = .proverbs
    case "21": self = .ecclesiastes
    case "22": self = .songOfSongs
    case "23": self = .isaiah
    case "24": self = .jeremiah
    case "25": self = .lamentations
    case "26": self = .ezekiel
    case "27": self = .daniel
    case "28": self = .hosea
    case "29": self = .joel
    case "30": self = .amos
    case "31": self = .obadiah
    case "32": self = .jonah
    case "33": self = .micah
    case "34": self = .nahum
    case "35": self = .habakkuk
    case "36": self = .zephaniah
    case "37": self = .haggai
    case "38": self = .zechariah
    case "39": self = .malachi
    case "40": self = .matthew
    case "41": self = .mark
    case "42": self = .luke
    case "43": self = .john
    case "44": self = .acts
    case "45": self = .romans
    case "46": self = .firstCorinthians
    case "47": self = .secondCorinthians
    case "48": self = .galatians
    case "49": self = .ephesians
    case "50": self = .philippians
    case "51": self = .colossians
    case "52": self = .firstThessalonians
    case "53": self = .secondThessalonians
    case "54": self = .firstTimothy
    case "55": self = .secondTimothy
    case "56": self = .titus
    case "57": self = .philemon
    case "58": self = .hebrews
    case "59": self = .james
    case "60": self = .firstPeter
    case "61": self = .secondPeter
    case "62": self = .firstJohn
    case "63": self = .secondJohn
    case "64": self = .thirdJohn
    case "65": self = .jude
    case "66": self = .revelation
    default: return nil
    }
  }
  // swiftlint:enable cyclomatic_complexity
  // swiftlint:enable function_body_length
}
