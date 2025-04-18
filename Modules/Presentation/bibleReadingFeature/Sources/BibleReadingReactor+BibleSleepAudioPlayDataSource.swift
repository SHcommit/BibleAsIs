//
//  BibleReadingReactor+BibleSleepAudioPlayDataSource.swift
//  BibleContentFeature
//
//  Created by 양승현 on 3/17/25.
//

import Foundation
import DomainEntity
import CoreInterface

/// 여기서 다음장 가버리면 안됨. 기존 재생중이던 오디오 플레이어가 제어해야함. 정지할 껀 정지하구 !! 타이머 멈출건 멈추구
extension BibleReadingReactor: BibleSleepAudioPlayDataSource {
  public func fetchCurrentVerse() -> DomainEntity.BibleVerse? {
    if sleepTimeVersePlayIndex >= numberOfItems {
      return nil
    }
    let _bibleVerse = currentState.bibleVerses[sleepTimeVersePlayIndex]
    let bibleVerse = BibleVerse(reference: _bibleVerse.reference, content: _bibleVerse.verseContent)
    return bibleVerse
  }
  
  public func fetchNextVerse() -> DomainEntity.BibleVerse? {
    increaseSleepTimeVersePlayIndex()
    if sleepTimeVersePlayIndex >= numberOfItems {
      return nil
    }
    let _bibleVerse = currentState.bibleVerses[sleepTimeVersePlayIndex]
    let bibleVerse = BibleVerse(reference: _bibleVerse.reference, content: _bibleVerse.verseContent)
    return bibleVerse
  }
  
  public func fetchPrevVerse() -> DomainEntity.BibleVerse? {
    decreaseSleepTimeVersePlayIndex()
    if sleepTimeVersePlayIndex < 0 {
      return nil
    }
    let _bibleVerse = currentState.bibleVerses[sleepTimeVersePlayIndex]
    let bibleVerse = BibleVerse(reference: _bibleVerse.reference, content: _bibleVerse.verseContent)
    return bibleVerse
  }
}
