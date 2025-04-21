//
//  BibleFeedReactor+BibleFeedAdapterDataSource.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 3/18/25.
//

import RxSwift
import ReactorKit
import Foundation
import DesignSystemItems
import DesignSystemInterface

extension BibleFeedReactor: BibleFeedAdapterDataSource {  
  public var isOnceInitialLoadingDone: Bool {
    currentState.isOnceInitialLoadingDone
  }
  
  public var isLoadingForNewSection: Bool {
    currentState.isLoadingForNewSection
  }
  
  public var isBibleReadingGardenSectionOnceLoaded: Bool {
    currentState.isBibleReadingGardenSectionOnceLoaded
  }
  
  public var isBibleDailyRandomVerseSectionOnceLoaded: Bool {
    currentState.isBibleDailyRandomVerseSectionOnceLoaded
  }
  
  public var isRecentlyReadVerseSectionOnceLoaded: Bool {
    currentState.isRecentlyReadVerseSectionOnceLoaded
  }
  
  public var isMccCheyneChallengeSectionOnceLoaded: Bool {
    currentState.isMccCheyneChallengeSectionOnceLoaded
  }
  
  public var isBibleReadingChallengeSectionOnceLoaded: Bool {
    currentState.isBibleReadingChallengeSectionOnceLoaded
  }
  
  public var isBibleHeartsSectionOnceLoaded: Bool {
    currentState.isBibleHeartsSectionOnceLoaded
  }
  
  public var isBibleNotesSectionOnceLoaded: Bool {
    currentState.isBibleNotesSectionOnceLoaded
  }
  
  public var numberOfFeedSections: Int {
    var numOFSections = 0
    guard currentState.isOnceInitialLoadingDone else { return numOFSections }
    if isBibleReadingGardenSectionOnceLoaded {
      numOFSections += 1
    } else {
      return numOFSections
    }
    
    if isBibleDailyRandomVerseSectionOnceLoaded {
      numOFSections += 1
    } else {
      return numOFSections
    }
    
    if isRecentlyReadVerseSectionOnceLoaded {
      numOFSections += 1
    } else {
      return numOFSections
    }
    
    if isMccCheyneChallengeSectionOnceLoaded {
      numOFSections += 1
    } else {
      return numOFSections
    }
    
    if isBibleReadingChallengeSectionOnceLoaded {
      numOFSections += 1
    } else {
      return numOFSections
    }
    
    if isBibleHeartsSectionOnceLoaded {
      numOFSections += 1
    } else {
      return numOFSections
    }
    if isBibleNotesSectionOnceLoaded {
      numOFSections += 1
    } else {
      return numOFSections
    }
    return numOFSections
  }
  
  public func numberOfFeedItems(of section: BibleFeedSection) -> Int {
    switch section {
    case .bibleReadingGarden:
      return 1
    case .bibleDailyRandomVerse:
      return 1
    case .recentlyReadVerse:
      return 1
    case .mccCheyneChallenge:
      return 1
    case .bibleReadingChallenge:
      return 2
    case .bibleHearts:
      if currentState.bibleHeartVerses.isEmpty {
        return 1
      } else if currentState.bibleHeartVerses.count >= 3 {
        return 3
      } else {
        return currentState.bibleHeartVerses.count
      }
    case .bibleNotes:
      if currentState.bibleNoteReferences.isEmpty {
        return 1
      } else if currentState.bibleNoteReferences.count >= 3 {
        return 3
      } else {
        return currentState.bibleNoteReferences.count
      }
    }
  }
}
