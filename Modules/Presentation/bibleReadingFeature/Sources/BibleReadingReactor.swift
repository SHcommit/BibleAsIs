//
//  BibleReadingReactor.swift
//  BibleContentFeature
//
//  Created by 양승현 on 2/14/25.
//

import Common
import RxSwift
import ReactorKit
import Foundation
import DomainEntity
import CoreInterface
import DomainInterface
import DesignSystemItems

public final class BibleReadingReactor: Reactor {
  // MARK: - Properties
  public var initialState: State = .init()
  
  private(set) var bibleReadingGardenSaveUseCase: BibleReadingGardenSaveUseCase
  
  private(set) var calendarService: CalendarServiceProtocol
  
  private(set) var bibleRepository: BibleRepository
  
  private(set) var fontSystemSettingsFetchUseCase: UserSystemSettingFontUseCase
  
  private(set) var recentBibleBookclipRepository: RecentBibleBookclipRepository
  
  private(set) var sleepTimeHandleRepository: SleepTimeHandleRepository
  
  /// 이게 numberOfVerses값이 되면, 진행 시간을 봐서 다음 꺼로 진행하던가 이제 중지하고, 플레이 완료됨을 저장하고 종료하자.
  private(set) var sleepTimeVersePlayIndex = 0
  
  /// isRestrictEntry = false인 경우 bibleReadingEntryItems가 없음.
  private(set) var isRestrictEntry: Bool
  
  private(set) var currentReadingEntryItem: BibleReadingEntryItem
  
  private(set) var bibleReadingEntryItemsForRange: [BibleReadingEntryItem]
  
  // 너 왜썼니?
  // 아마 디비 동시접근 문제 때매 한건데 디비 동시접근 내부적으로 serial queue추가함
//  private(set) var backgroundQuque = DispatchQueue(
//    label: "com.journeyOfFaith.app.bibleContentReactor.queue",
//    qos: .default)
  
  // MARK: - BibleViewDataSource Wrapper
  public var numberOfSections: Int = 1
  
  public var numberOfItems: Int {
    return currentState.bibleVerses.count
  }
  
  public var isOldTestament: Bool {
    currentReadingEntryItem.bibleBook.isOldTestament
  }
  
  public var numberOfChapters: Int {
    currentReadingEntryItem.bibleBook.numberOfChapters
  }
  
  // MARK: - Lifecycle
  /// isRestrictEntry = false인 경우 bibleReadingEntryItems가 없음.
  /// 이경우 북클립 offset저장하기.
  public init(
    currentReadingEntryItem: BibleReadingEntryItem,
    bibleReadingEntryItemsForRange: [BibleReadingEntryItem],
    isRestrictEntry: Bool,
    calendarService: CalendarServiceProtocol,
    bibleRepository: BibleRepository,
    recentBibleBookclipRepository: RecentBibleBookclipRepository,
    fontSystemSettingsFetchUseCase: UserSystemSettingFontUseCase,
    bibleReadingGardenSaveUseCase: BibleReadingGardenSaveUseCase,
    sleepTimeHandleRepository: SleepTimeHandleRepository
  ) {
    self.sleepTimeHandleRepository = sleepTimeHandleRepository
    self.recentBibleBookclipRepository = recentBibleBookclipRepository
    self.calendarService = calendarService
    self.bibleReadingGardenSaveUseCase = bibleReadingGardenSaveUseCase
    self.isRestrictEntry = isRestrictEntry
    self.currentReadingEntryItem = currentReadingEntryItem
    self.bibleReadingEntryItemsForRange = bibleReadingEntryItemsForRange
    self.bibleRepository = bibleRepository
    self.fontSystemSettingsFetchUseCase = fontSystemSettingsFetchUseCase
  }
  
  // MARK: - ReactorKit
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .none:
      return .empty()
    case .viewDidLoad:
      return fetchBibleVerseStream()
    case .highlightAppend(index: let index, range: let range, colorIndex: let colorIndex):
      return addHighlightStream(index: index, range: range, colorIndex: colorIndex)
    case .highlightDelete(index: let index, id: let id):
      return deleteHighlightStream(index: index, id: id)
    case .noteAppend(index: let index, bibleNote: let bibleNote):
      return appendNoteStream(withIndex: index, bibleNote: bibleNote)
    case .noteRemove(index: let index):
      return deleteNoteStream(with: index)
    case .heartToggle(index: let index, isOnHeart: let isOnHeart):
      return toggleHeartStatusStream(with: index, isOnHeart: isOnHeart)
    case .fontUpdated(let updatedFontSize):
      return Observable.concat([
        .just(.updatedFontHandle(updatedFontSize)),
        .just(.updatedFontHandlingCompletion(true)),
        .just(.updatedFontHandlingCompletion(false))
      ])
    case .readCompleted:
      return saveBibleReadingGardenLogStream()
    case .updatedOffset(
      offsetY: let offsetY, contentSizeHeight: let contentSizeHeight, visibleSizeHeight: let visibleSizeHeight):
      return handleUpdatedOffsetStream(
        offsetY: offsetY,
        contentSizeHeight: contentSizeHeight,
        visibleSizeHeight: visibleSizeHeight)
    case .sleepAudioIsPicked(let sleepTimeOption):
      return saveDefaultSleepTimeOptionStreamByOwnerPickStream(sleepTimeOption)
    case .sleepAudioPlayBySleepAudioPlayer:
      return fetchSleepTimeOptionStream()
    case .sleepAudioPlaybackExpired:
      return sleepAudioPlayBackExpredStream()
    case .sleepAudioPalyElapsedSecondsSave(let elapsedSeconds, let andPlayPrevChapter):
      return sleepAudioPlayElapsedSecondsSaveStream(
        elapsedSeconds: elapsedSeconds,
        andPlayPrevChapter: andPlayPrevChapter)
    case .sleepAudioCanceldByUser(elapsedSeconds: let elapsedSeconds):
      return cancelSleepAudioByUserStream(withElapsedSeconds: elapsedSeconds)
    }
  }
    
  // MARK: - Reduce
  // swiftlint:disable:next all
  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .bibleVersesSet(let verses):
      newState.bibleVerses = verses
    case .bookChapterVerseNameSet(let title):
      newState.bookChapterVerseName = title
    case .none:
      break
    case .highlightAppend(let index, let highlightItem):
      newState.bibleVerses[index].highlights.append(highlightItem)
      newState.updatedhighlight = highlightItem
    case .highlightRemove(let index, let id):
      newState.bibleVerses[index].highlights.removeAll(where: {$0.id == id})
    case .error(let errorMessage):
      newState.errorMessage = errorMessage
    case .noteAppend(index: let index, let noteItem):
      newState.bibleVerses[index].note = noteItem
      newState.updatedNoteIndex = index
    case .noteRemove(let index):
      newState.bibleVerses[index].note = nil
      newState.updatedNoteIndex = index
    case .heartToggle(index: let index, isOnHeart: let isOnHeart):
      newState.bibleVerses[index].isOnHeart = isOnHeart
    case .shouldReload(let reload):
      newState.shouldReload = reload
    case .updatedFontHandle(let fontSize):
      for i in newState.bibleVerses.indices {
        newState.bibleVerses[i].fontSize = fontSize
      }
    case .updatedFontHandlingCompletion(let handled):
      newState.updatedFontHandlingCompletion = handled
    case .noteUpdatedCompletion(let completed):
      newState.updatedNoteCompletion = completed
    case .readCompletionSaveStateHandle(let savedState):
      newState.readCompletionSaveState = savedState
    case .readCompletionSaveStateCompletion(let hasCompleted):
      newState.hasHandledReadCompletion = hasCompleted
    case .shouldStartAudioPlay(let shouldStart):
      newState.shouldStartAudioPlay = shouldStart
      if shouldStart {
        newState.isExecutingAudioMode = true
      }
    case .audioPlayRemainingDurationSet(let remainingaudioPlayTime):
      newState.remainingaudioPlayTime = remainingaudioPlayTime
    case .audioPlayTimeDoneForPlayOnceSet(let hasDone):
      newState.audioPlayTimeDoneForPlayOnce = hasDone
    case .wannaPlayPrevChapterSet(let wannaPlayPrevChapter):
      newState.wannaPlayPrevChapter = wannaPlayPrevChapter
    case .shouldPlayOtherChapterSet(let shouldPlayOtherChapter):
      newState.shouldPlayOtherChapter = shouldPlayOtherChapter
    case .audioPlayCancelByUserSetCompletion(let hasCompleted):
      newState.audioPlayCancelByUserSetCompletion = hasCompleted
      if hasCompleted {
        newState.isExecutingAudioMode = false
      }
    }
    return newState
  }
  
  // MARK: - Stream Helpers
  private func handleUpdatedOffsetStream(
    offsetY: CGFloat,
    contentSizeHeight: CGFloat,
    visibleSizeHeight: CGFloat
  ) -> Observable<Mutation> {
    if isRestrictEntry {
      /// 범위 제한 없는 경우만.
      return .just(.none)
    }
    // MARK: 주의
    // 이거 그리고 비동기로 감싸면 사용자가 바로 진입 -> 뒤로가기 할 때
    // 미처 이게 뒤늦게 저장되니까 홈 화면 에선 연동 안된거로 보일 수 있음.
    // 내부적으로 저장했는데, 저장하기도전에 이전 화면에서 이전 데이터를 가져오니까.
    // 조심하자!
    let newClip = RecentBibleClip(
      testament: .init(isOldTestament: isOldTestament),
      book: currentReadingEntryItem.bibleBook,
      chapter: currentReadingEntryItem.chapter,
      offsetY: offsetY,
      contentSizeHeight: contentSizeHeight,
      visibleSizeHeight: visibleSizeHeight)
    recentBibleBookclipRepository.saveRecentClip(newClip)
    print(Self.self, "저장 완료 최근 읽은ㄴ 위치")
    return .just(.none)
  }
}

// MARK: - Helpers
extension BibleReadingReactor {
  internal func increaseSleepTimeVersePlayIndex() {
    sleepTimeVersePlayIndex += 1
  }
  
  internal func decreaseSleepTimeVersePlayIndex() {
    sleepTimeVersePlayIndex -= 1
  }
}
