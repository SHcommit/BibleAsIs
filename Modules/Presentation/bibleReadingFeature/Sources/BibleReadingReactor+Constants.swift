//
//  BibleReadingReactor+Constants.swift
//  BibleReadingFeature
//
//  Created by 양승현 on 4/10/25.
//

import Foundation
import ReactorKit
import DomainEntity
import DesignSystemItems

extension BibleReadingReactor {
  public typealias UserPickSleepTimerTotalDuration = TimeInterval
  public typealias SleepTimerCurrentDuration = TimeInterval
  
  public enum Action {
    case none
    case viewDidLoad
    case highlightAppend(index: Int, range: NSRange, colorIndex: HighlightColorIndex)
    case highlightDelete(index: Int, id: Int)
    case noteAppend(index: Int, bibleNote: BibleNote)
    
    /// 이거로 최근 성경 구절 어디까지 읽었는지를 저장하게됨.
    /// 그런데 사용자가 다음장 넘기고 바로 뒤로가면 저장이 안되는 문제 있음.
    /// 리엑터한테 도달하는게 느린가!?
    case updatedOffset(offsetY: CGFloat, contentSizeHeight: CGFloat, visibleSizeHeight: CGFloat)
    
    case noteRemove(index: Int)
    case heartToggle(index: Int, isOnHeart: Bool)
    
    case fontUpdated(CGFloat)
    case readCompleted
    
    /// 설정에서 들어온 경우
    case sleepAudioIsPicked(SleepTimerOption)
    /// 오디오 플레이어에 의해 자동으로 들어온 경우
    case sleepAudioPlayBySleepAudioPlayer
    /// 오디오 시간 진행 모두 끝난 경우
    case sleepAudioPlaybackExpired
    /// 사용자가 다른 챕터로 이동해야 하는 경우 현재까지 진행한 시간을 저장하자.
    /// 이전챕터로 이동할 경우 true, 다음챕터로 이동해야할 경우 false
    case sleepAudioPalyElapsedSecondsSave(elapsedSeconds: TimeInterval, andPlayPrevChapter: Bool)
    
    /// 오디오 취소 한 경우
    case sleepAudioCanceldByUser(elapsedSeconds: TimeInterval)
  }
  
  public enum Mutation {
    case bibleVersesSet([BibleVerseItem])
    case bookChapterVerseNameSet(String)
    case highlightAppend(index: Int, BibleVerseHighlightItem)
    case highlightRemove(index: Int, id: Int)
    
    case noteAppend(index: Int, BibleVerseNoteItem)
    case noteRemove(index: Int)
    case noteUpdatedCompletion(Bool)
    
    case heartToggle(index: Int, isOnHeart: Bool)
    case shouldReload(Bool)
    
    case updatedFontHandle(CGFloat)
    case updatedFontHandlingCompletion(Bool)
    
    case readCompletionSaveStateHandle(BibleReadingSaveCompletionState)
    case readCompletionSaveStateCompletion(Bool)
    
    case shouldStartAudioPlay(Bool)
    //    case audioPlayRemainingDurationSet(SleepTimerCurrentDuration, UserPickSleepTimerTotalDuration)
    case audioPlayRemainingDurationSet(TimeInterval)
    case audioPlayTimeDoneForPlayOnceSet(Bool)
    
    //    case audioPlayCancelByUserSet(elapsedSeconds: TimeInterval)
    case audioPlayCancelByUserSetCompletion(Bool)
    
    case wannaPlayPrevChapterSet(Bool)
    case shouldPlayOtherChapterSet(Bool)
    
    case none
    case error(String)
  }
  
  public struct State {
    var bibleVerses: [BibleVerseItem] = []
    var updatedhighlight: BibleVerseHighlightItem?
    var updatedNote: BibleVerseNoteItem?
    var bookChapterVerseName = ""
    var errorMessage = ""
    
    var readCompletionSaveState: BibleReadingSaveCompletionState = .notSaved
    var isExecutingAudioMode = false
    
    /// 이거는 동시에 실행이 될 수없는것임.
    /// 그래서 노트 추가 또는 삭제의 경우에 활용됨
    var updatedNoteIndex: Int?
    
    /// true 이전챕터, false 다음챕터 재생
    var wannaPlayPrevChapter: Bool = false
    
    // MARK: - Bind
    var shouldReload: Bool = false
    var updatedFontHandlingCompletion = false
    var hasHandledReadCompletion = false
    var updatedNoteCompletion = false
    
    var audioPlayTimeDoneForPlayOnce: Bool = false
    var shouldStartAudioPlay: Bool = false
    var remainingaudioPlayTime: TimeInterval = 0.0
    
    var shouldPlayOtherChapter: Bool = false
    var audioPlayCancelByUserSetCompletion: Bool = false
  }
}
