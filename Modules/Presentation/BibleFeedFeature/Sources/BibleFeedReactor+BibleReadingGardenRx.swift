//
//  BibleFeedReactor+BibleReadingGarden.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 3/18/25.
//

import RxSwift
import ReactorKit
import Foundation
import DomainEntity
import DesignSystemItems

extension BibleFeedReactor {
  // MARK: - AsObservable
  private func fetchMonthlyReadingGardenCommitHistoriesAsObservable(year: Int, month: Int) -> Observable<BibleGardenItem> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      if month - 1 < 0 {
        assertionFailure("에러가 나면 안됨")
        observer.onError(CommonError.referenceDeallocated)
        return Disposables.create()
      }
      
      readingGardenCommitFetchRepository.fetchMonthlyReadingGardenCommitHistories(
        in: year,
        month: month
      ) { [weak self] result in
        guard let self else { observer.onError(CommonError.referenceDeallocated); return }
        
        switch result {
        case .success(let dailyReadingGardenEntities):
          var newGardenItem = currentState.bibleReadingGardenItems[month-1]
          let analyzedGardenHitmap = bibleReadingGardenAnalyzer.makeBibleGardenHitmap(
            for: year,
            month: month,
            byReadingGardens: dailyReadingGardenEntities)
          let isThisMonth = calendarService.isCurrentMonth(year: year, month: month)
          newGardenItem.isThisMonth = isThisMonth
          newGardenItem.isSixWeeks = calendarService.isSixWeeks(year: year, month: month)
          newGardenItem.gardens = analyzedGardenHitmap
          observer.onNext(newGardenItem)
          observer.onCompleted()
        case .failure(let failure):
          observer.onError(failure)
        }
      }
      
      return Disposables.create()
    }
  }
    
  private func fetchAnnualReadingGardenCommitHistoriesAsObservable(year: Int) -> Observable<[BibleGardenItem]> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      
      readingGardenCommitFetchRepository.fetchAnnualReadingGardenCommitHistories(year: year) { [weak self] result in
        guard let self else {
          observer.onError(CommonError.referenceDeallocated)
          return
        }
        
        switch result {
        case .success(let dailyBibleReadingEntriesForAnnual):
          let today = calendarService.today(with: Date())
          let weekdayOfToday = today.weekday
          var bibleReadingGardenItems: [BibleGardenItem] = []
          
          for (monthIndex, dailyReadingGardenEntities) in dailyBibleReadingEntriesForAnnual.enumerated() {
            let month = monthIndex + 1
            let analyzedGardenHitmap = bibleReadingGardenAnalyzer.makeBibleGardenHitmap(
              for: year,
              month: month,
              byReadingGardens: dailyReadingGardenEntities)
            let isThisMonth = calendarService.isCurrentMonth(year: year, month: month)
            let isSixWeeks = calendarService.isSixWeeks(year: year, month: month)
            
            let newBibleReadingGardenItem = BibleGardenItem(
              month: .init(rawValue: month) ?? .january,
              weekday: weekdayOfToday,
              isThisMonth: isThisMonth,
              isSixWeeks: isSixWeeks,
              gardens: analyzedGardenHitmap)
            bibleReadingGardenItems.append(newBibleReadingGardenItem)
          }
          observer.onNext(bibleReadingGardenItems)
          observer.onCompleted()
        case .failure(let error):
          observer.onError(error)
        }
      }
      
      return Disposables.create()
    }
  }
  
  // MARK: - Sream
  
  /// 기본 데이터 받고 state 업데이트하는 로직
  /// - Parameters hasUserPickYear: 사용자가 직접 연도를 선택했는가? 여부를 물음.
  ///     사용자가 연도를 선택했다면, selectionYear가 변경됨
  func fetchAnnualReadingGardenCommitHistoriesBaseStream(
    year: Int,
    hasUserPickYear: Bool = false
  ) -> Observable<Mutation> {
    fetchAnnualReadingGardenCommitHistoriesAsObservable(year: year)
      .map { Mutation.annualReadingGardenCommitsFetched(
        year: year,
        newBibleGardenItems: $0,
        hasUserPickYear: hasUserPickYear)
      }
  }
  
  /// 이 함수를 사용하기 전에는 반드시 특정 년도에 대한 currentState.bibleReadingGardenItems.count == 12로 세팅되어 있어야 합니다.
  ///   fetchAnnualReadingGardenCommitHistoriesStream(year:) 이 함수를 호출하여 currentState를 초기화 해두어야 합니다.
  /// 그러니까 전체적인 year에 대한 each month's BibleGardenItems 데이터를 한번 받은 후에 사용해야 좋습니다.
  /// 이 경우는 하루가 지났다거나, 사용자가 다시 앱을 들어왔을 때 요일이 변경된 경우
  ///   즉, 특정한 요일을 업데이트 해야할 경우 사용합니다.
  func fetchMonthlyReadingGardenCommitHistoriesStream(year: Int, month: Int) -> Observable<Mutation> {
    return Observable.concat([
      fetchMonthlyReadingGardenCommitHistoriesAsObservable(year: year, month: month)
        .map { Mutation.monthlyReadingGardenCommitsFetched(
          year: year,
          month: month,
          newBibleGardenItem: $0)},
      .just(.monthlyReadingGardenCommitFetchedCompletion(true)),
      .just(.monthlyReadingGardenCommitFetchedCompletion(false))
    ])
  }
  
  // MARK: Notes
  /// 이 섹션의 모든 데이터만 업데이트 하는 경우
  /// year를 기준으로 DB에 저장된 모든 monthly Garden Hitmaps for  garden 데이터를 가져옵니다.
  /// - Parameters isUserPickYear: 사용자가 선택한 연도인가?
  func fetchAnnualReadingGardenCommitHistoriesStream(year: Int, isUserPickYear: Bool) -> Observable<Mutation> {
    return Observable.concat([
      fetchAnnualReadingGardenCommitHistoriesBaseStream(year: year, hasUserPickYear: isUserPickYear),
      .just(.annualReadingGardenCommitsFetchedCompletion(true)),
      .just(.annualReadingGardenCommitsFetchedCompletion(false))
    ])
  }
}
