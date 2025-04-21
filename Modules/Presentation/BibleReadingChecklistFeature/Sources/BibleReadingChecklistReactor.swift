//
//  BibleReadingChecklistReactor.swift
//  BibleReadingChecklistFeature
//
//  Created by 양승현 on 3/4/25.
//

import Common
import RxSwift
import ReactorKit
import Foundation
import DomainEntity
import CoreInterface
import DomainInterface
import DesignSystemItems

public final class BibleReadingChecklistReactor: Reactor {
  public typealias TestamentIndexPath = IndexPath
  public typealias ChapterIndex = Int
  /// yy-MM-dd
  public typealias SelectedDateString = String
  
  public struct ChapterReadingReference {
    let testamentIndexPath: TestamentIndexPath
    let chapterIndex: Int
    var alreadyRead: Bool
    var dateString: String?
  }
  
  public enum Action {
    case viewDidLoad
    case specificTestamentOfBookTap(TestamentIndexPath)
    case toggableChapterReadTap(TestamentIndexPath, ChapterIndex)
    case readDateSelect(TestamentIndexPath, ChapterIndex, SelectedDateString)
  }
  
  public enum Mutation {
    case none
    case checkableDailyReadingItemsSet([CheckableBibleDailyReadingItem])
    case specificTestamentOfBookTapForExpandingUpdate(IndexPath?)
    case shouldRefresh(Bool)
    
    case toggableChapterSet(ChapterReadingReference)
    case updatedToggableChapterSet(TestamentIndexPath?)
    case descriptionSet(BibleDailyReadingPlanDescriptionItem)
    case descriptionHasUpdated(Bool)
    
    case readDateUpdated(ChapterReadingReference)
  }
  
  public struct State {
    var descriptionItem: BibleDailyReadingPlanDescriptionItem = .init(
      startDateStr: "",
      totalReadChapters: 0,
      continuousChallengingDays: "",
      maxContinuousChallengingDays: "",
      oldTestamentStructureStatus: [("#F28787", 0.01), ("#F2CD87", 0.01), ("#A0F287", 0.01), ("#87E8F2", 0.01)],
      newTestamentStructureStatus: [("#F28787", 0.01), ("#F2CD87", 0.01), ("#A0F287", 0.01),
                                    ("#87E8F2", 0.01), ("#87A7F2", 0.01)]
    )
    
    var checkableBibleDailyReadingItems: [CheckableBibleDailyReadingItem] = []
    
    // MARK: - for bindable
    var shouldRefresh: Bool = false
    var expandableIndexPathUpdated: IndexPath?
    
    /// 둘이 한 쌍
    var toggableChapterRefreshBookByUpdating: TestamentIndexPath?
    var descriptionUpdate: Bool = false
    
    /// 혹시 데이터를 받지 못했지만 reloadData가 내부적으로 호출될 수 있음.
    /// 이럴때 크러시남. 그래서
    /// 아예 initially fetched되지 않을 경우엔 numOfSections = 0를 반환해서 방지하자.
    var hasInitiallyFetched: Bool = false
  }
  
  // MARK: - Properties
  public var initialState: State = .init()
  
  private(set) var bibleReadingPlanUseCase: DailyBibleReadingChecklistUseCase
  
  /// 데일리 특정 book chapter's verse를 읽었는지 여부 파악
  /// 이에 따라 메인 화면의 잔디가 증가, 감소 됩니다
  private(set) var bibleReadingGardenSaveUseCase: BibleReadingGardenSaveUseCase
  
  private(set) var bibleReadingGardenDeleteUseCase: BibleReadingGardenDeleteUseCase
  
  private(set) var calendarService: CalendarServiceProtocol
  
  var dateController: BibleDateController {
    BibleDateController.shared
  }
  
  // MARK: - Lifecycle
  public init(
    bibleReadingPlanUseCase: DailyBibleReadingChecklistUseCase,
    bibleReadingGardenSaveUseCase: BibleReadingGardenSaveUseCase,
    bibleReadingGardenDeleteUseCase: BibleReadingGardenDeleteUseCase,
    calendarService: CalendarServiceProtocol
  ) {
    self.bibleReadingGardenSaveUseCase = bibleReadingGardenSaveUseCase
    self.bibleReadingGardenDeleteUseCase = bibleReadingGardenDeleteUseCase
    self.bibleReadingPlanUseCase = bibleReadingPlanUseCase
    self.calendarService = calendarService
  }
  
  // MARK: - Reactor
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return Observable.concat([
        fetchAllCheckableTestamentsOfBibleItems().map { Mutation.checkableDailyReadingItemsSet($0) },
        fetchDescriptionItemStream(shouldCallDescriptionHasUpdated: false),
        .just(.shouldRefresh(true)),
        .just(.shouldRefresh(false))
      ])
    case .specificTestamentOfBookTap(let indexPath):
      return Observable.concat([
        .just(Mutation.specificTestamentOfBookTapForExpandingUpdate(indexPath)),
        .just(Mutation.specificTestamentOfBookTapForExpandingUpdate(nil))
      ])
    case .toggableChapterReadTap(let testamentIndexPath, let chapterIndex):
      return Observable.concat([
        updateTestamentOfBookChapterReadStateStream(
          forTestamentOfBookIndexPath: testamentIndexPath,
          chapterIndex: chapterIndex
        ).map { .toggableChapterSet($0) },
        .just(.updatedToggableChapterSet(testamentIndexPath)),
        .just(.updatedToggableChapterSet(nil))
      ]).concat(fetchDescriptionItemStream(shouldCallDescriptionHasUpdated: true))
    case .readDateSelect(let testamentIndexPath, let chapterIndex, let selectedDateString):
      return updateForSelectingReadDateStream(
        testamentIndexPath: testamentIndexPath,
        chapterIndex: chapterIndex,
        readDateString: selectedDateString)
    }
  }
  
  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .none:
      break
    case .checkableDailyReadingItemsSet(let items):
      newState.checkableBibleDailyReadingItems = items
    case .specificTestamentOfBookTapForExpandingUpdate(let expandableIndexPath):
      if let expandableIndexPath {
        newState.checkableBibleDailyReadingItems[expandableIndexPath.row].isExpended.toggle()
      }
      newState.expandableIndexPathUpdated = expandableIndexPath
    case .shouldRefresh(let shouldRefresh):
      newState.shouldRefresh = shouldRefresh
      if shouldRefresh, !newState.hasInitiallyFetched {
        newState.hasInitiallyFetched = true
      }
    case .toggableChapterSet(let chapterReference):
      let bookRow = chapterReference.testamentIndexPath.row
      let chapterIndex = chapterReference.chapterIndex
      let alreadyRead = chapterReference.alreadyRead
      newState.checkableBibleDailyReadingItems[bookRow].chapterItems[chapterIndex].alreadyRead = alreadyRead
      newState.checkableBibleDailyReadingItems[bookRow]
        .chapterItems[chapterIndex]
        .dateString = chapterReference.dateString
      if alreadyRead {
        newState.checkableBibleDailyReadingItems[bookRow].currentValue += 1
      } else {
        newState.checkableBibleDailyReadingItems[bookRow].currentValue -= 1
        if newState.checkableBibleDailyReadingItems[bookRow].currentValue <= 0 {
          newState.checkableBibleDailyReadingItems[bookRow].currentValue = 0
        }
      }
    case .updatedToggableChapterSet(let indexPath):
      newState.toggableChapterRefreshBookByUpdating = indexPath
    case .descriptionSet(let description):
      newState.descriptionItem = description
      
      if !newState.hasInitiallyFetched {
        newState.hasInitiallyFetched = true
      }
    case .descriptionHasUpdated(let bool):
      newState.descriptionUpdate = bool
    case .readDateUpdated(let reference):
      newState.checkableBibleDailyReadingItems[reference.testamentIndexPath.row]
        .chapterItems[reference.chapterIndex]
        .dateString = reference.dateString
    }
    return newState
  }
}

private extension BibleReadingChecklistReactor {
  func fetchAlreadyReadEntriesStream(for book: BibleBook) -> Observable<[DailyBibleReadingChapterEntry]> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      bibleReadingPlanUseCase.fetchAlreadyReadEntries(book: book) { result in
        switch result {
        case .success(let entries):
          observer.onNext(entries)
          observer.onCompleted()
        case .failure(let failure):
          observer.onError(failure)
        }
      }
      
      return Disposables.create()
    }
  }
  
  /// 66권 따로 비동기로 받고, index에 따라 순서 정렬하기
  func fetchAllCheckableTestamentsOfBibleItems() -> Observable<[CheckableBibleDailyReadingItem]> {
    let observables = BibleBook.allBooks.enumerated().map { (index, book) in
      fetchAlreadyReadEntriesStream(for: book)
        .flatMap { [weak self] entries -> Observable<(Int, CheckableBibleDailyReadingItem)> in
          guard let self else { return .empty() }
          let item = (index, makeChapterItems(book: book, readChapterEntries: entries))
          return .just(item)
        }
    }
    return Observable
      .zip(observables)
      .map { items in
        items.sorted { $0.0 < $1.0 }.map { $0.1 }
      }
  }
  
  func fetchTotalReadChaptersStream() -> Observable<Int> {
    Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      bibleReadingPlanUseCase.fetchTotalReadChapters { result in
        switch result {
        case .success(let success):
          observer.onNext(success)
          observer.onCompleted()
        case .failure(let failure):
          observer.onError(failure)
        }
      }
      return Disposables.create()
    }
  }
  
  func fetchBibleStructureCategyReadProcessAsObservable() -> Observable<[BibleStructureCategory: (readChapters: Int, totalChapters: Int)]> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      
      bibleReadingPlanUseCase.fetchAllBibleStructureReadingProgress { result in
        switch result {
        case .success(let entry):
          observer.onNext(entry)
          observer.onCompleted()
        case .failure(let failure):
          observer.onError(failure)
        }
      }
      return Disposables.create()
    }
  }
  
  /// 사용자가 챕터 읽음 or  읽지 않음을 표시할 때 마다 이 성경 읽기 표의 총 읽은 개수 등 plan description은 변경됨.
  ///
  /// 이거는 이제 특정 챕터를 읽거나, 특정한 챕터를 읽고 date표기할 때! 이제 이 읽기 표의 description info를 업데이트함.
  /// 매번하자.
  /// 사용자에게 최신 정보를 보여주자.
  /// - 화면이 보이지 않으면 갱신은 안해도될듯 어차피 재사용큐에서 꺼내져 나올때 갱신된 데이터 받으니까
  /// - 사용자가 보이는 화면이라면 (visible cell's or indexPath) 해당 섹션은 업데이트하자.
  ///
  /// shouldCallDescriptionHasUpdated 이거는 이제 description 영역만 따로 리로드 하기 위함
  func fetchDescriptionItemStream(shouldCallDescriptionHasUpdated: Bool) -> Observable<Mutation> {
    
    let oldTestamentStructureHexColors = initialState.descriptionItem.oldTestamentStructureStatus.map { $0.barHexColor }
    
    let newTestamentStructureHexColors = initialState.descriptionItem.newTestamentStructureStatus.map { $0.barHexColor }
    
    let descriptionUpdates: [Observable<Mutation>] = [
      .just(.descriptionHasUpdated(true)),
      .just(.descriptionHasUpdated(false))
    ]
    
    let descriptionUpdateObservable = Observable.zip(
      fetchInitialStartDateStream(),
      fetchContinuousChallengingDaysStream(),
      fetchTotalReadChaptersStream(),
      fetchMaxContinuousChallengingDaysStream(),
      fetchBibleStructureCategyReadProcessAsObservable()
    )
      .map { startDate, days, totalReadChapters, maximumContinuousDays, bibleStructureReadingProcessEntry in
        let oldTestaments: [BibleStructureCategory] = [.oldTestamentLaw, .oldTestamentHistory, .oldTestamentPoetry, .oldTestamentProphecy]
        
        let newTestaments: [BibleStructureCategory] = [
          .newTestamentGospels, .newTestamentHistory, .newTestamentPaulineEpistles, .newTestamentGeneralEpistles, .newTestamentProphecy
        ]
        
        let convertedOldTestamentsReadPercentage = oldTestaments.map {
          let entry = bibleStructureReadingProcessEntry[$0]
          let readChapters = entry?.readChapters ?? 0
          let totalChapters = $0.totalChapters
          return CGFloat(readChapters) / CGFloat(totalChapters) * 100.0
        }
        
        let convertedNewTestamentsReadPercentage = newTestaments.map {
          let entry = bibleStructureReadingProcessEntry[$0]
          let readChapters = entry?.readChapters ?? 0
          let totalChapters = $0.totalChapters
          return CGFloat(readChapters) / CGFloat(totalChapters) * 100.0
        }
        
        let oldTestamentStructureStatus = convertedOldTestamentsReadPercentage.enumerated().map { (i, e) in
          let hexColor = oldTestamentStructureHexColors[i]
          return (hexColor, e)
        }
        
        let newTestamentStructureStatus = convertedNewTestamentsReadPercentage.enumerated().map { (i, e) in
          let hexColor = newTestamentStructureHexColors[i]
          return (hexColor, e)
        }
        
        return Mutation.descriptionSet(
          .init(startDateStr: startDate,
                totalReadChapters: totalReadChapters,
                continuousChallengingDays: "\(days) 일",
                maxContinuousChallengingDays: "\(maximumContinuousDays) 일",
                oldTestamentStructureStatus: oldTestamentStructureStatus,
                newTestamentStructureStatus: newTestamentStructureStatus)
        )
      }
    return Observable.concat(shouldCallDescriptionHasUpdated ? [
      descriptionUpdateObservable] + descriptionUpdates : [descriptionUpdateObservable]
    )
  }
  
  /// 사용자가 챕터 읽음 or  읽지 않음을 표시할 때 마다 호출되는 toggle stream
  ///
  /// 만약 사용자가 처음부터 chapter표시할 때 길게 눌렀을때 alreadyRead + readDate선택 두 개 연이어 할 경우에도 불림.
  func updateTestamentOfBookChapterReadStateStream(
    forTestamentOfBookIndexPath: IndexPath,
    chapterIndex: Int,
    alreadyRead: Bool? = nil,
    withReadDateString: String? = nil
  ) -> Observable<ChapterReadingReference> {
    let specificBookEntry = currentState
      .checkableBibleDailyReadingItems[forTestamentOfBookIndexPath.row]
    var dailyBibleReadingChapterItem = specificBookEntry.chapterItems[chapterIndex]
    dailyBibleReadingChapterItem.alreadyRead.toggle()
    
    // MARK: Garden
    let today = calendarService.getTodayComponents()
    /// 읽기 완료는 완료하고 컴플리션 주어야함!
    let newStateReadingLogEntry = BibleReadingGardenLogEntry(
      year: today.year ?? 2025, month: today.month ?? 07, day: today.day ?? 07,
      book: specificBookEntry.book,
      chapter: dailyBibleReadingChapterItem.reference.chapterNumber)
    if dailyBibleReadingChapterItem.alreadyRead {
      bibleReadingGardenSaveUseCase.saveBibleReadingGarden(
        for: newStateReadingLogEntry, completion: {_ in })
    } else {
      bibleReadingGardenDeleteUseCase.deleteBibleReadingGarden(
        for: newStateReadingLogEntry, completion: {_ in })
    }
    
    // MARK: Bible Checklist
    /// 롱 제스쳐에 의한!
    if let alreadyRead, alreadyRead {
      dailyBibleReadingChapterItem.alreadyRead = true
    }
    
    if !dailyBibleReadingChapterItem.alreadyRead {
      dailyBibleReadingChapterItem.dateString = nil
    } else if dailyBibleReadingChapterItem.alreadyRead, let withReadDateString {
      /// 롱 제스쳐에 의한!!
      dailyBibleReadingChapterItem.dateString = withReadDateString
    }
    
    var newEntry = DailyBibleReadingChapterEntry(
      book: specificBookEntry.book,
      chapter: dailyBibleReadingChapterItem.reference.chapterNumber,
      alreadyRead: dailyBibleReadingChapterItem.alreadyRead,
      date: nil)
    if let dateStr = dailyBibleReadingChapterItem.dateString {
      newEntry.date = dateController.toYYmmddDate(from: dateStr)
    }
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      // MARK: 이거 update썼는데 로직상 insert로 변경
//      bibleReadingPlanUseCase.update(newEntry) { result in
      bibleReadingPlanUseCase.insert(newEntry) { result in
        switch result {
        case .success:
          observer.onNext(
            .init(
              testamentIndexPath: forTestamentOfBookIndexPath,
              chapterIndex: chapterIndex,
              alreadyRead: newEntry.alreadyRead,
              dateString: dailyBibleReadingChapterItem.dateString))
          observer.onCompleted()
        case .failure(let failure):
          observer.onError(failure)
        }
      }
      return Disposables.create()
    }
  }
  
  /// 읽었으면 읽었다고 표시한 날짜 read date string만 갱신
  /// 안읽었으면 string, 다 갱신.
  func updateForSelectingReadDateStream(
    testamentIndexPath indexPath: IndexPath,
    chapterIndex: ChapterIndex,
    readDateString: String
  ) -> Observable<Mutation> {
    let readingItem: CheckableBibleDailyReadingItem = currentState.checkableBibleDailyReadingItems[indexPath.row]
    let alreadyRead = readingItem.chapterItems[chapterIndex].alreadyRead
    if alreadyRead {
      /// readDate 이거만 갱신하면됨.
      /// 그래야 현재 읽은 챕터 개수는 중복 증가 안함.
      let readingChapterEntry: DailyBibleReadingChapterEntry = .init(
        book: readingItem.book,
        chapter: readingItem.chapterItems[chapterIndex].reference.chapterNumber,
        alreadyRead: true, date: dateController.toYYmmddDate(from: readDateString))
      return Observable.concat([
        Observable.create { [weak self] observer in
          guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
          
          // 이미 읽은 체크는 있는데, 언제 읽었는지 날짜 체크한 거 업데이트하는 거니까 !
          // MARK: - 업데이트 썻는데 insert로
//          bibleReadingPlanUseCase.update(readingChapterEntry) { result in
          bibleReadingPlanUseCase.insert(readingChapterEntry) { result in
            switch result {
            case .success:
              observer.onNext(.readDateUpdated(.init(
                testamentIndexPath: indexPath, chapterIndex: chapterIndex,
                alreadyRead: true,
                dateString: readDateString)))
              observer.onCompleted()
            case .failure(let failure):
              observer.onError(failure)
            }
          }
          
          return Disposables.create()
        },
        .just(.updatedToggableChapterSet(indexPath)),
        .just(.updatedToggableChapterSet(nil))
      ])
    } else {
      return Observable.concat([
        updateTestamentOfBookChapterReadStateStream(
          forTestamentOfBookIndexPath: indexPath,
          chapterIndex: chapterIndex,
          alreadyRead: true, withReadDateString: readDateString
        ).map { .toggableChapterSet($0) },
        .just(.updatedToggableChapterSet(indexPath)),
        .just(.updatedToggableChapterSet(nil))
      ]).concat(fetchDescriptionItemStream(shouldCallDescriptionHasUpdated: true))
    }
  }
}
