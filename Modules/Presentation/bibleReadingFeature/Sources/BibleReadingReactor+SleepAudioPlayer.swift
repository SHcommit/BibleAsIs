//
//  BibleReadingReactor+SleepAudioPlayer.swift
//  BibleContentFeature
//
//  Created by 양승현 on 3/17/25.
//

import RxSwift
import ReactorKit
import Foundation
import DomainEntity

extension BibleReadingReactor {
  // MARK: - AsObservable
  
  // MARK: - Stream
  func sleepAudioPlayElapsedSecondsSaveStream(
    elapsedSeconds: TimeInterval,
    andPlayPrevChapter: Bool
  ) -> Observable<Mutation> {
    guard var currentSleepTimeEntry = sleepTimeHandleRepository.fetchUserPickSleepTime() else {
      return .just(.error("앱 시스템에 문제가 발생해 재생할 수 없습니다."))
    }
    currentSleepTimeEntry.currentDuration += elapsedSeconds
    sleepTimeHandleRepository.saveUserPickSleepTime(currentSleepTimeEntry)
    return Observable.concat([
      .just(.wannaPlayPrevChapterSet(andPlayPrevChapter)),
      .just(.shouldPlayOtherChapterSet(true)),
      .just(.shouldPlayOtherChapterSet(false))
    ])
  }
  
  /// 지금까지 플레이한 정보를 저장한다.
  /// 이유는 피드 화면에서 최근 재생했던 챕터 구간을 보여줄려고 했는데 일단 보류 그럼에도 로직은 만들어둠
  func cancelSleepAudioByUserStream(withElapsedSeconds elapsedSeconds: TimeInterval) -> Observable<Mutation> {
    guard var currentSleepTimeEntry = sleepTimeHandleRepository.fetchUserPickSleepTime() else {
      return Observable.concat([
        .just(.audioPlayCancelByUserSetCompletion(true)),
        .just(.audioPlayCancelByUserSetCompletion(false))
      ])
    }
    
    currentSleepTimeEntry.currentDuration += elapsedSeconds
    sleepTimeHandleRepository.saveUserPickSleepTime(currentSleepTimeEntry)
    return Observable.concat([
      .just(.audioPlayCancelByUserSetCompletion(true)),
      .just(.audioPlayCancelByUserSetCompletion(false))
    ])
  }
  
  func saveDefaultSleepTimeOptionStreamByOwnerPickStream(_ sleepTimeOption: SleepTimerOption) -> Observable<Mutation> {
    let newEntry = SleepTimeEntry(
      book: currentReadingEntryItem.bibleBook,
      chapter: currentReadingEntryItem.chapter,
      verse: 1,
      timerOption: sleepTimeOption,
      currentDuration: 0, paused: false,
      playOnceAlreadyDone: false)
    sleepTimeHandleRepository.saveUserPickSleepTime(newEntry)
    return Observable.concat([
      .just(.audioPlayRemainingDurationSet(sleepTimeOption.toTimeInterval)),
      .just(.shouldStartAudioPlay(true)),
      .just(.shouldStartAudioPlay(false))
    ])
  }
  
  func fetchSleepTimeOptionStream() -> Observable<Mutation> {
    guard var entry = sleepTimeHandleRepository.fetchUserPickSleepTime() else {
      return .just(.error("지정된 슬립 타이머 시간이 없습니다. 다시 시도해주세요."))
    }
    entry.book = currentReadingEntryItem.bibleBook
    entry.chapter = currentReadingEntryItem.chapter
    entry.verse = 0
    entry.paused = false
    sleepTimeHandleRepository.saveUserPickSleepTime(entry)
    let remainingaudioPlayTime = entry.timerOption.toTimeInterval - entry.currentDuration
    if remainingaudioPlayTime <= 0 {
      entry.playOnceAlreadyDone = true
      sleepTimeHandleRepository.saveUserPickSleepTime(entry)
      return Observable.concat([
        .just(.audioPlayTimeDoneForPlayOnceSet(true)),
        .just(.audioPlayTimeDoneForPlayOnceSet(false))
      ])
    } else {
      sleepTimeHandleRepository.saveUserPickSleepTime(entry)
      // 시작
      return Observable.concat([
        .just(.audioPlayRemainingDurationSet(remainingaudioPlayTime)),
        .just(.shouldStartAudioPlay(true)),
        .just(.shouldStartAudioPlay(false))
      ])
    }
  }
  
  /// handleSleepTimerDidEnd에 의해 호출되는 거였는데, ( 타이머 시간 만료 )
  /// 지금은 홈 화면에 일단 오디오 어디 진행했는지는 안보여주려고 함. ( 기능 사용 안함 )
  func sleepAudioPlayBackExpredStream() -> Observable<Mutation> {
    if var currentEntry = sleepTimeHandleRepository.fetchUserPickSleepTime() {
      currentEntry.verse = numberOfItems
      currentEntry.currentDuration = currentEntry.timerOption.toTimeInterval
      currentEntry.paused = true
      currentEntry.playOnceAlreadyDone = true
      sleepTimeHandleRepository.saveUserPickSleepTime(currentEntry)
    } else {
      let newEntry: SleepTimeEntry = .init(
        book: currentReadingEntryItem.bibleBook,
        chapter: currentReadingEntryItem.chapter,
        verse: numberOfItems, timerOption: .fiveMinutes, currentDuration: 300.0, paused: true, playOnceAlreadyDone: true)
      sleepTimeHandleRepository.saveUserPickSleepTime(newEntry)
    }
    return .just(.none)
  }
}
