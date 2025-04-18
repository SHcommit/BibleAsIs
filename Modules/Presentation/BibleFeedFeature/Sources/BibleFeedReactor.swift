//
//  BibleFeedReactor.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 3/18/25.
//

import Common
import RxSwift
import ReactorKit
import Foundation
import DomainEntity
import CoreInterface
import DomainInterface
import DesignSystemItems

public final class BibleFeedReactor: Reactor {
  public enum Action {
    case viewDidLoad
    case viewWillAppear
    
    // MARK: - BibleGarden
    case monthlyReadingGardenCommitsFetch(year: Int, month: Int)
    case annualReadingGardenCommitsFetch(year: Int, isUserPickYear: Bool)
    
    /// viewWilAppear할 때 이전 저장한 날짜와 다를 경우 새로 데이터 fetch.
    case randomBibleVerseFetch
    
    /// 매번 패치
    case recentBibleBookclipFetch
    
    /// 매번 패치
    case dailyReadingChecklistCardFetch(forNewSection: Bool)
    
    /// 매번 패치
    case bibleHeartVersesFetch(forNewSection: Bool)
    
    case bibleNoteVersesFetch(forNewSection: Bool)
  }
  
  /// nested Mutation보다 그냥 1depth + 주석 달자.
  public enum Mutation {
    case none
    case unexpetedErrorMessageOccured(String)
    
    // - BibleGarden
    case monthlyReadingGardenCommitsFetched(year: Int, month: Int, newBibleGardenItem: BibleGardenItem)
    case annualReadingGardenCommitsFetched(year: Int, newBibleGardenItems: [BibleGardenItem], hasUserPickYear: Bool)
    
    /// for binding
    case monthlyReadingGardenCommitFetchedCompletion(Bool)
    /// 이 경우 특정한 month. IndexPath만 업데이트 합니다
    /// Bind
    case annualReadingGardenCommitsFetchedCompletion(Bool)
    
    // - WeeklyRandomVerses
    case weeklyRandomVersesFetched([[BibleVerse]])
    case weeklyRandomVersesFetchedCompletion(Bool)
    
    // - RecentBibleBookclip
    case recentBibleBookclipFetched(RecentReadBibleBookclipItem)
    case recentBibleBookclipFetchedCompletion(Bool)
    
    // - MccCheyne
    case mccCheyneCompletion(Bool)
    
    // - DailyReadingChecklist
    case dailyReadingChecklistCardFetched(DailyBibleReadingChecklistCardItem)
    case dailyReadingChecklistDescriptionFetched(BibleDailyReadingPlanDescriptionItem)
    case dailyReadingChecklistCardFetchedCompletion(Bool)
    
    // - BibleHearts
    case bibleHeartVersesFetched([BibleVerse])
    case bibleHeartVersesFetchedCompletion(Bool)
    
    case notesFetched(versesForNote: [BibleVerse], notes: [BibleNote])
    case notesFetchedCompletion(Bool)
    
    // MARK: - Refresh
    /// 아무리 isBibleReadinGardenSectionOnceLoaded, isBIbleDailyRadomVerseSectionOnceLoaded == true가 됬다 한들, 초기 로딩 성공이 되지 않으면,
    /// refresh를 하지 않도록 설계함.
    ///
    /// 맨 처음 화면이 보여질 때는 무저건 refresh에 의해서, initialLoadingDone이 true로 되야하구, 그 이후에 순차적으로 사용자가 스크롤을 내릴 때 Section을 로딩하도록
    /// 설계해봄
    /// Bind
    /// viewDidLoad 시점
    case isInitialLoadingDone
    case isInitialLoadingDoneCompletion(Bool)
    /// 처음 새로운 섹션을 받아올 때 사용됨. 여러 섹션이 공유하면서 사용하니까 true -> false처리 꼭해야함.
    /// 화면이 하나라 받아오는 새로운 섹션은 단 한개임.
    case isLoadingForNewSectionSet(Bool)
    
    /// 일반적인 뷰 윌 어피어.
    case viewWillAppearRefreshedCompletion(Bool)
  }
  
  public struct State {
    // Garden Property, Binding
    var bibleReadingGardenItems: [BibleGardenItem] = []
    var selectionYearForBibleGarden: Int
    var currentYearForBibleGarden: Int
    var lastLoginDateEntity: LastLoginDateEntity?
    var recentlyUpdatedMonth: Int?
    
    /// bind this properties for reload specific month garden hitmap
    var monthlyReadingGardenCommitFetchedCompletion: Bool = false
    /// bind
    var annualReadingGardenCommitsFetchedCompletion: Bool = false
    
    // WeeklyRandomVerses
    var bibleRandomVerses: [[BibleVerse]] = []
    
    /// for binding
    var bibleRandomVersesFetchedCompletion: Bool = false
    
    // recentReadBIbleBookclip
    var recentReadBibleBookclipItem: RecentReadBibleBookclipItem?
    
    // for binding
    var recentBibleBookclipFetchedCompletion = false
    
    /// 초기에 로딩이 되었으면 true로 바뀌고 그 이후부터는 변경되지 않음
    /// 처음에는 섹션 1, 2, 3만 로드할것임 + 4(맥체인은 알아서 잘 받아옴)
    /// 이후에는 사용자가 스크롤 할 때만 로딩하자.
    /// 아 completion없이 이거 불변수 하나로만 바인딩하니까 리로드 엄청 호출됨 ㅡ.ㅡ
    var isOnceInitialLoadingDone = false
    /// 얘로 바인딩 걸자.... true -> false처리해야 더이상의 무분별한 호출이 없음. 외부에서 처음 로딩완려됬는지 여부는 위에
    /// isOnceInitialLoadingDone을 사용하고.
    var isOnceInitialLoadingDoneCompletion = false
    
    // dailyReadingChecklist
    var dailyReadingChecklistCardItem: DailyBibleReadingChecklistCardItem?
    var dailyReadingChecklistDescriptionItem: BibleDailyReadingPlanDescriptionItem = .init(
      startDateStr: "",
      totalReadChapters: 0,
      continuousChallengingDays: "",
      maxContinuousChallengingDays: "",
      oldTestamentStructureStatus: [("#F28787", 0.01), ("#F2CD87", 0.01), ("#A0F287", 0.01), ("#87E8F2", 0.01)],
      newTestamentStructureStatus: [("#F28787", 0.01), ("#F2CD87", 0.01), ("#A0F287", 0.01),
                                    ("#87E8F2", 0.01), ("#87A7F2", 0.01)])
    var dailyReadingChecklistCardItemFetchedCompletion = false
    
    /// 이거는 최초로 한번 받아올 때, 이게 true되고, fetrchedCompletion = true되면,
    /// fetchedCompletion true일 때 아래 프로퍼티 최초로 한번 받아온게 트루라면 그때는 isnert section else reload section하자.
    var newSectionInitiallyShow = false
    
    var bibleHeartVerses: [BibleVerse] = []
    var bibleHeartVersesFetchedCompletion = false
    
    var bibleNoteVerses: [BibleVerse] = []
    var bibleNoteReferences: [BibleNote] = []
    var bibleNoteVersesFetchedCompletion = false
    
    /// bind this propertis for showing unexpected error.
    /// engore errorMessage when string: "" has set
    var unexpectedErrorMessage: String = ""
    
    var viewWillAppearRefreshed = false
    
    // MARK: - Section has already Loaded?
    /// reduce내부에서 데이터 받을때 단 한번만 해주면 됌 ㅎㅎ
    var isBibleReadingGardenSectionOnceLoaded = false
    var isBibleDailyRandomVerseSectionOnceLoaded = false
    var isRecentlyReadVerseSectionOnceLoaded = false
    var isMccCheyneChallengeSectionOnceLoaded = false
    var isBibleReadingChallengeSectionOnceLoaded = false
    var isBibleHeartsSectionOnceLoaded = false
    var isBibleNotesSectionOnceLoaded = false
    
    var isLoadingForNewSection = false
  }
  
  // MARK: - Properties
  /// 처음 뷰윌 어피어에는 refresh호출 ㄴㄴ.
  /// 그 이후부터는 뷰 윌 어피어 때마다 사용자가 접속한게 날짜가 날라졌다면 갱신해야함
  private var isInitialViewWillAppearDone: Bool = false
  
  public let initialState: State
  
  private(set) var readingGardenCommitFetchRepository: BibleReadingGardenCommitFetchRepository
  
  private(set) var bibleReadingGardenAnalyzer: BibleReadingAnalyzable
  
  private(set) var calendarService: CalendarServiceProtocol
  
  private(set) var randomVerseFetchUseCase: DailyBibleRandomVerseFetchUseCase
  
  // MARK: viewWillAppear할 때마다 사용자가 접속한 기록이 최신인지 여부를 파악해야 한다 그 후에 날짜가 바뀐지 여부를 파악하고
  /// 피드에서 갱신해야할 데이터들을 갱신해서 리로드 데이터 해주자 (어디가 바뀔지도모르고 사용자가 어디 스크롤해둔지도 확인해야함
  private(set) var ownerLastLoginDateUseCase: OwnerLastLoginDateUseCase
  
  private(set) var recentBibleBookclipUseCase: RecentBibleBookclipUseCase
  
  private(set) var dailyReadingUseCase: DailyBibleReadingChecklistUseCase
  
  private(set) var bibleHeartFetchUseCase: BibleHeartFetchUseCase
  
  private(set) var bibleNoteUseCase: BibleNoteUseCase
  
  private(set) var bibleVerseFetchUseCase: BibleVerseFetchUseCase
  
  private var entryDate: DateComponents
  
  public init(
    readingGardenCommitFetchRepository: BibleReadingGardenCommitFetchRepository,
    bibleReadingGardenAnalyzer: BibleReadingAnalyzable,
    calendarService: CalendarServiceProtocol,
    randomVerseFetchUseCase: DailyBibleRandomVerseFetchUseCase,
    ownerLastLoginDateUseCase: OwnerLastLoginDateUseCase,
    recentBibleBookclipUseCase: RecentBibleBookclipUseCase,
    dailyReadingUseCase: DailyBibleReadingChecklistUseCase,
    bibleHeartFetchUseCase: BibleHeartFetchUseCase,
    bibleNoteUseCase: BibleNoteUseCase,
    bibleVerseFetchUseCase: BibleVerseFetchUseCase
  ) {
    self.readingGardenCommitFetchRepository = readingGardenCommitFetchRepository
    self.bibleReadingGardenAnalyzer = bibleReadingGardenAnalyzer
    self.calendarService = calendarService
    self.randomVerseFetchUseCase = randomVerseFetchUseCase
    self.ownerLastLoginDateUseCase = ownerLastLoginDateUseCase
    self.recentBibleBookclipUseCase = recentBibleBookclipUseCase
    self.dailyReadingUseCase = dailyReadingUseCase
    self.bibleHeartFetchUseCase = bibleHeartFetchUseCase
    self.bibleNoteUseCase = bibleNoteUseCase
    self.bibleVerseFetchUseCase = bibleVerseFetchUseCase
    
    entryDate = calendarService.getTodayComponents()
    let _curYear = calendarService.getTodayComponents().year ?? 2025
    initialState = State(selectionYearForBibleGarden: _curYear, currentYearForBibleGarden: _curYear)
  }
  
  private func isSameDate(_ newDate: DateComponents) -> Bool {
    entryDate.year == newDate.year && entryDate.month == newDate.month && entryDate.day == newDate.day
  }
  
  // MARK: - Reactor
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      /// 들어올 떄 오늘 날짜를 받고, 이를 기반으로 반영.
      /// 오늘 로그인한날짜 최신날짜인지 여부는 이제... 앱 델리게이트에서 하도록 해보자.
      /// 이거는 처음에 정한 section 1,2,3 map인가?
      return viewDidLoadStraem()
    case .viewWillAppear:
      /// 초기에 들어온 경우는 뷰 윌 어피어 때 갱신x. 이유는 초기 viewDidLoad에서 했기 때문
      if !isInitialViewWillAppearDone {
        isInitialViewWillAppearDone = true
        return .just(.none)
      }
      
      // MARK: 사용자가 최근 로그인 한 정보가 일치하지 않다면, 최신 요일로 리프래시 하기.
      // 그외에 형광펜, 노트는 그냥 조건 걸지말구 리프래시하기!
      // date를 받아와서 이전 날짜랑 다른지 비교하기.
      // 다르다면, weeklyVerse 이거도 받아오기.
      // 말씀의 정원 받아오기.
      // 최근 본 성경 구절 받아오기
      // 데일리 맥 체인지 받아오기
      // 성경 읽독 챌린지 받아오기
      // 좋아요 받아오기
      // 노트 받아오기.
      // -> 사용자가 그런데 그날 최초로 한번 접속해서 어디까지 내렸느지 is Once여부로 파악하기. ( true된것만 받아오기 )
      
      // 이게 isDirty이런거 불 넣어서 판단할수있고 각각의 특정 섹션만 리로드할수있는 Stream함수 다 구현해 두긴 함.
      let today = calendarService.getTodayComponents()
      let isNewDate = !isSameDate(today)
      if isNewDate {
        entryDate = today
      }
      return Observable.concat([
        refreshData(isNewDate: isNewDate),
        .just(.viewWillAppearRefreshedCompletion(true)),
        .just(.viewWillAppearRefreshedCompletion(false))
      ])
      
      // MARK: BibleGarden
    case .monthlyReadingGardenCommitsFetch(year: let year, month: let month):
      return fetchMonthlyReadingGardenCommitHistoriesStream(year: year, month: month)
    case .annualReadingGardenCommitsFetch(year: let year, isUserPickYear: let isUserPick):
      return fetchAnnualReadingGardenCommitHistoriesStream(year: year, isUserPickYear: isUserPick)
      // BibleRandomVerse
    case .randomBibleVerseFetch:
      /// 사용자가 최근 로그인한 날짜는 유저디폴츠에 저장. 그리고 매번 가져올 때 현재 따끈따끈한날짜와 다를 경우
      /// 새로운 날 받아오기.
      if ownerLastLoginDateUseCase.isNewDay() {
        /// 새로운 날 받아오기 newDay니까 디비에 오늘 로그인한 정보 저장하기 이건 여기서 말고 다른데서 하자.
        /// 새로운 날 받아오는 여부는 viewWillAppear시점에서 매번 체크함 거기서 업데이트 해야 함.
        let todayIndex = ownerLastLoginDateUseCase.getTodayDayIndex()
        return fetchWeeklyRandomVersesStream(fromDay: todayIndex)
      } else {
        print("요일 변화 없음")
        return .just(.none)
      }
    case .recentBibleBookclipFetch:
      return fetchRecentBibleBookclipStream()
    case .dailyReadingChecklistCardFetch(forNewSection: let forNewSection):
      return fetchDailyReadingChecklistStream(forNewSection: forNewSection)
    case .bibleHeartVersesFetch(forNewSection: let forNewSection):
      return fetchHeartVersesStream(forNewSection: forNewSection)
    case .bibleNoteVersesFetch(forNewSection: let forNewSection):
      return fetchNotesStream(forNewSection: forNewSection)
    }
  }
  
  // swiftlint:disable:next cyclomatic_complexity
  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .none:
      break
    case .unexpetedErrorMessageOccured(let errorMessage):
      newState.unexpectedErrorMessage = errorMessage
      // MARK: - Bible Garden
    case .monthlyReadingGardenCommitsFetched(_, month: let month, newBibleGardenItem: let newGardenItem):
      newState.recentlyUpdatedMonth = month
      newState.bibleReadingGardenItems[month-1] = newGardenItem
    case .monthlyReadingGardenCommitFetchedCompletion(let hasCompleted):
      newState.monthlyReadingGardenCommitFetchedCompletion = hasCompleted
    case .annualReadingGardenCommitsFetched(let year, let newBibleGardenItems, let hasUserPickYear):
      if hasUserPickYear {
        newState.selectionYearForBibleGarden = year
      } else {
        newState.currentYearForBibleGarden = year
      }
      newState.bibleReadingGardenItems = newBibleGardenItems
      if !newState.isBibleReadingGardenSectionOnceLoaded {
        newState.isBibleReadingGardenSectionOnceLoaded = true
      }
    case .annualReadingGardenCommitsFetchedCompletion(let hasCompleted):
      newState.annualReadingGardenCommitsFetchedCompletion = hasCompleted
      // MARK: - ViewDidLoad
      /// 초기 단 한번만 쓰임
    case .isInitialLoadingDoneCompletion(let hasDone):
      newState.isOnceInitialLoadingDoneCompletion = hasDone
    case .isInitialLoadingDone:
      newState.isOnceInitialLoadingDone = true
      // MARK: - RandomVerses
    case .weeklyRandomVersesFetched(let newWeeklyRandomVerses):
      newState.bibleRandomVerses = newWeeklyRandomVerses
      if !newState.isBibleDailyRandomVerseSectionOnceLoaded {
        newState.isBibleDailyRandomVerseSectionOnceLoaded = true
      }
    case .weeklyRandomVersesFetchedCompletion(let hasCompleted):
      newState.bibleRandomVersesFetchedCompletion = hasCompleted
      // MARK: RecentBibleBookClip
    case .recentBibleBookclipFetched(let recentBookclipItem):
      newState.recentReadBibleBookclipItem = recentBookclipItem
      if !newState.isRecentlyReadVerseSectionOnceLoaded {
        newState.isRecentlyReadVerseSectionOnceLoaded = true
      }
    case .recentBibleBookclipFetchedCompletion(let hasCompletion):
      newState.recentBibleBookclipFetchedCompletion = hasCompletion
    case .mccCheyneCompletion(let hasCompleted):
      if hasCompleted {
        newState.isMccCheyneChallengeSectionOnceLoaded = hasCompleted
      }
    case .dailyReadingChecklistCardFetched(let fetchedItem):
      newState.dailyReadingChecklistCardItem = fetchedItem
    case .dailyReadingChecklistCardFetchedCompletion(let hasCompleted):
      newState.dailyReadingChecklistCardItemFetchedCompletion = hasCompleted
      
      newState.newSectionInitiallyShow = hasCompleted
      if newState.isBibleReadingChallengeSectionOnceLoaded {
        newState.newSectionInitiallyShow = false
      }
      if !newState.isBibleReadingChallengeSectionOnceLoaded {
        newState.isBibleReadingChallengeSectionOnceLoaded = true
      }
    case .isLoadingForNewSectionSet(let isLoading):
      newState.isLoadingForNewSection = isLoading
    case .bibleHeartVersesFetched(let verses):
      newState.bibleHeartVerses = verses
    case .bibleHeartVersesFetchedCompletion(let hasCompleted):
      newState.bibleHeartVersesFetchedCompletion = hasCompleted
      
      newState.newSectionInitiallyShow = hasCompleted
      if newState.isBibleHeartsSectionOnceLoaded {
        newState.newSectionInitiallyShow = false
      }
      if !newState.isBibleHeartsSectionOnceLoaded {
        newState.isBibleHeartsSectionOnceLoaded = true
      }
      
    case .notesFetched(versesForNote: let verses, notes: let notes):
      newState.bibleNoteVerses = verses
      newState.bibleNoteReferences = notes
    case .notesFetchedCompletion(let hasCompleted):
      newState.bibleNoteVersesFetchedCompletion = hasCompleted
      
      newState.newSectionInitiallyShow = hasCompleted
      if newState.isBibleNotesSectionOnceLoaded {
        newState.newSectionInitiallyShow = false
      }
      if !newState.isBibleNotesSectionOnceLoaded {
        newState.isBibleNotesSectionOnceLoaded = true
      }
    case .viewWillAppearRefreshedCompletion(let hasRefreshed):
      newState.viewWillAppearRefreshed = hasRefreshed
    case .dailyReadingChecklistDescriptionFetched(let newBibleReadingChecklistDescriptionItem):
      newState.dailyReadingChecklistDescriptionItem = newBibleReadingChecklistDescriptionItem
    }
      return newState
  }
  
  // MARK: - Helpers
}
extension BibleFeedReactor {
  func viewDidLoadStraem() -> Observable<Mutation> {
    let todayIndex = ownerLastLoginDateUseCase.getTodayDayIndex()
    return Observable.concat([
      fetchAnnualReadingGardenCommitHistoriesBaseStream(year: currentState.currentYearForBibleGarden),
      fetchWeeklyRandomVersesBaseStream(fromDay: todayIndex),
      fetchRecentBibleBookclipBaseStream(),
      .just(Mutation.mccCheyneCompletion(true)),
      .just(.isInitialLoadingDone),
      .just(Mutation.isInitialLoadingDoneCompletion(true)),
      .just(Mutation.isInitialLoadingDoneCompletion(false))
    ])
  }
  
  private func refreshData(isNewDate: Bool) -> Observable<Mutation> {
    /// 최초 로그인시
    var baseSequence: [Observable<Mutation>] = [
      fetchAnnualReadingGardenCommitHistoriesBaseStream(year: currentState.currentYearForBibleGarden),
      fetchRecentBibleBookclipBaseStream()
    ]
    if isNewDate {
      let todayIndex = ownerLastLoginDateUseCase.getTodayDayIndex()
      baseSequence.append(fetchWeeklyRandomVersesBaseStream(fromDay: todayIndex))
    }
    
    /// 맥체인은 알아서 내부적으로 처리함
    if currentState.isBibleReadingChallengeSectionOnceLoaded {
      baseSequence.append(fetchDailyReadingCehcklistBaseStream())
    }
    
    if currentState.isBibleHeartsSectionOnceLoaded {
      baseSequence.append(fetchHeartVersesBaseStream())
    }
    
    if currentState.isBibleNotesSectionOnceLoaded {
      baseSequence.append(_fetchNotesBaseStream())
    }
    
    return Observable.concat(baseSequence)
  }
}
