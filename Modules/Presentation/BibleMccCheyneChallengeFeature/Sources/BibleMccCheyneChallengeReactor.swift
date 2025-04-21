//
//  BibleMccCheyneChallengeReactor.swift
//  JourneyOfFaithMyActivityFeatureDemoApp
//
//  Created by 양승현 on 2/26/25.
//

import Common
import RxSwift
import Foundation
import ReactorKit
import DomainEntity
import CoreInterface
import DomainInterface
import DesignSystemItems

// MARK: - DesignSystemInterface로 분리해야함
import DesignSystem

public final class BibleMccCheyneChallengeReactor: Reactor {
  public enum Action {
    case reload
    case update(specificDailyChallenge: IndexPath, readCompleted: Bool)
    case selectionDayUpdate(indexPath: IndexPath)
    case NextDayChallengeMovePrepare
  }
  
  public enum Mutation {
    case currentDaySet(RecentMccCheyneDay)
    case mccCheyneChallengeEntrySet(DailyMccCheyneEntity)
    case unexpectedErrorOccured(String)
    case checkboxUpdate(IndexPath?)
    
    /// 선택된 day 업데이트.
    case selectedDaySet(Int)
    
    /// 전체 리로드
    case refreshSet(Bool)
    
    /// 챌린지들만 리로드
    case challengesRefresh(Bool)
    
    case currentDayUpdatedByCompletingAllChallenges(Bool?)
    
    case none
  }
  
  public struct State {
    typealias shouldMove = Bool
    
    var hasInitiallyFetched: Bool = false
    
    /// 오늘 해야할 챌린지. 그러나 이 Day는 모든 챌린지를 완료할 때마다 업데이트 되어짐
    var currentDate: RecentMccCheyneDay = .init(currentDay: 1)
    
    /// 모든 이동은 선택된 데이트에 의해 관련 챌린지들이 보여짐
    var selectedDay: Int = 1
    
    /// challenges 담겨있는 entity
    var challengeEntity: DailyMccCheyneEntity = .init(day: 1, references: [])
    
    /// 모든 섹션들 리로드
    var refresh: Bool = false
    
    /// 이게 특정 day만 선택되서 그건 애니메이션 처리된 상태에서 챌린지들만 리로드
    var refreshChallenges: Bool = false
    
    var updatedCheckboxIndexPath: IndexPath?
    
    /// 모든 체크박스들이 체크된 후
    /// 만약, 새로운 currentDay로 이동할 수 있다면, true, 아닐 경우 false ( 모든 챌린지 끝남 )
    /// 그렇게 업데이트 된 후엔 nil로 초기화 하자.
    var currentDayUpdated: shouldMove?
    
    var unexpectedErrorString = ""
    
    var currentDay: Int {
      currentDate.currentDay
    }
  }
  
  // MARK: - Properties
  public var initialState: State = State()
  
  private var disposeBag = DisposeBag()
  
  private let calendarService: CalendarServiceProtocol
  
  /// 오늘 진행중인 챌린지
  var currentChallengeDay: Int {
    currentState.currentDay
  }
  
  /// Owner가 현재 바라보는 선택된 챌린지
  var selectedChallengeDay: Int {
    currentState.selectedDay
  }
  
  var challenges: [String] {
    currentState.challengeEntity.generateChallenges()
  }
  
  public var updatedCurrentDay: ((Int) -> Void)?
  
  // MARK: - Dependencies
  private(set) var bibleMccCheyneRepository: BibleMccCheyneRepository
  
  private(set) var ownerMccCheyneRepository: OwnerBibleMccCheyneRepository
  
  /// 데일리 특정 book chapter's verse를 읽었는지 여부 파악
  /// 이에 따라 메인 화면의 잔디가 증가, 감소 됩니다
  private let bibleReadingGardenSaveUseCase: BibleReadingGardenSaveUseCase
  
  private let bibleReadingGardenDeleteUseCase: BibleReadingGardenDeleteUseCase
  
  // MARK: - Lifecycle
  public init(
    bibleMccCheyneRepository: BibleMccCheyneRepository,
    ownerMccCheyneRepository: OwnerBibleMccCheyneRepository,
    bibleReadingGardenSaveUseCase: BibleReadingGardenSaveUseCase,
    bibleReadingGardenDeleteUseCase: BibleReadingGardenDeleteUseCase,
    calendarService: CalendarServiceProtocol
  ) {
    self.bibleMccCheyneRepository = bibleMccCheyneRepository
    self.ownerMccCheyneRepository = ownerMccCheyneRepository
    self.bibleReadingGardenSaveUseCase = bibleReadingGardenSaveUseCase
    self.bibleReadingGardenDeleteUseCase = bibleReadingGardenDeleteUseCase
    self.calendarService = calendarService
  }
  
  // MARK: - Reactor
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .reload:
      return Observable.concat([
        fetchCurrentMccCheyneChallengeDayStream(),
        fetchSpecificChallengeStream(with: currentChallengeDay),
        .just(.selectedDaySet(currentChallengeDay)),
        .just(.refreshSet(true)),
        .just(.refreshSet(false))
      ])
    case .update(specificDailyChallenge: let indexPath, readCompleted: let hasRead):
      let today = calendarService.getTodayComponents()
      let challengeKey = currentState.challengeEntity.sortedBookKeys()[indexPath.item]
      let refRanges = currentState.challengeEntity.rangeReferences(for: challengeKey)

      let newEntries = refRanges.map {
        BibleReadingGardenLogEntry(
          year: today.year ?? 2025, month: today.month ?? 7, day: today.day ?? 7,
          book: $0.book, chapter: $0.chapter)
      }
      if hasRead {
        for newEntry in newEntries {
          bibleReadingGardenSaveUseCase.saveBibleReadingGarden(for: newEntry, completion: { _ in })
        }
      } else {
        for newEntry in newEntries {
          bibleReadingGardenDeleteUseCase.deleteBibleReadingGarden(for: newEntry, completion: { _ in })
        }
      }
      
      return Observable.concat([
        updateChallengeEntryStream(challenge: indexPath, hasRead: hasRead),
        .just(.checkboxUpdate(indexPath)),
        .just(.checkboxUpdate(nil))
      ])
      /// Day는 1일 부터 시작입니다!
    case .selectionDayUpdate(indexPath: let indexPath):
      return Observable.concat([
        fetchSpecificChallengeStream(with: indexPath.item+1),
        .just(.selectedDaySet(indexPath.item+1)),
        .just(.challengesRefresh(true)),
        .just(.challengesRefresh(false))
      ])
      
      /// 현재 모든 챌린지를 완료 했을 경우!
    case .NextDayChallengeMovePrepare:
      return Observable.concat([
        updateCurrentChallengeDayByCompletingAllChallengesStream()
      ])
    }
  }
  
  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .currentDaySet(let recentMccCheyneDay):
      newState.currentDate = recentMccCheyneDay
    case .mccCheyneChallengeEntrySet(let dailyMccCheyneEntity):
      newState.challengeEntity = dailyMccCheyneEntity
      if !newState.hasInitiallyFetched {
        newState.hasInitiallyFetched = true
      }
    case .unexpectedErrorOccured(let errorMsg):
      newState.unexpectedErrorString = errorMsg
    case .refreshSet(let bool):
      newState.refresh = bool
    case .checkboxUpdate(let indexPath):
      newState.updatedCheckboxIndexPath = indexPath
    case .selectedDaySet(let sectionItem):
      newState.selectedDay = sectionItem
    case .none:
      break
    case .challengesRefresh(let refresh):
      newState.refreshChallenges = refresh
    case .currentDayUpdatedByCompletingAllChallenges(let updatedCurrentDay):
      newState.currentDayUpdated = updatedCurrentDay
    }
    return newState
  }
}
