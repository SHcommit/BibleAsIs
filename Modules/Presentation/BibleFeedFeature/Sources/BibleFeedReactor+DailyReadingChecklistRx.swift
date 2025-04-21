//
//  BibleFeedReactor+DailyReadingChecklistRx.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 3/19/25.
//

import Common
import RxSwift
import ReactorKit
import Foundation
import DomainEntity
import DesignSystemItems

extension BibleFeedReactor {
  // MARK: - AsObservable
  
  // MARK: For Description
  func fetchInitialStartDateAsObservable() -> Observable<String> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      dailyReadingUseCase.fetchStartDate { result in
        switch result {
        case .success(let date):
          var convertedInitialStartDateString = "미정"
          if let date = date {
            convertedInitialStartDateString = "\(BibleDateController.shared.convertYYMMDDString(from: date))"
          }
          observer.onNext(convertedInitialStartDateString)
          observer.onCompleted()
        case .failure:
          observer.onNext("미정")
          observer.onCompleted()
        }
      }
      return Disposables.create()
    }
  }
  
  func fetchContinuousChallengingDaysAsObservable() -> Observable<Int> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      dailyReadingUseCase.fetchContinuousChallengingDays { result in
        switch result {
        case .success(let continuousDays):
          observer.onNext(continuousDays)
          observer.onCompleted()
        case .failure(let failure):
          observer.onError(failure)
        }
      }
      return Disposables.create()
    }
  }
  
  func fetchMaxContinuousChallengingDaysAsObservable() -> Observable<Int> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      dailyReadingUseCase.fetchMaxContinuousChallengingDays { result in
        switch result {
        case .success(let continuousDays):
          observer.onNext(continuousDays)
          observer.onCompleted()
        case .failure(let failure):
          observer.onError(failure)
        }
      }
      return Disposables.create()
    }
  }
  
  func fetchTotalReadChaptersAsObservable() -> Observable<Int> {
    Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      dailyReadingUseCase.fetchTotalReadChapters { result in
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
      
      dailyReadingUseCase.fetchAllBibleStructureReadingProgress { result in
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

  // MARK: For Card
  private func fetchDailyReadingChecklistAsObservable() -> Observable<DailyBibleReadingChecklistCardItem> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      
      dailyReadingUseCase.fetchTotalReadChapters { result in
        switch result {
        case .success(let currentReadChapters):
          let allChapters = BibleBook.allChapters
          let percentage = Double(currentReadChapters)/Double(allChapters)*100.0
          
          observer.onNext(.init(
            isExecutingState: currentReadChapters > 0,
            currentReadingPercentage: percentage))
          observer.onCompleted()
        case .failure(let error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
  
  // MARK: - Stream
  func fetchDescriptionItemStream() -> Observable<Mutation> {
    let oldTestamentStructureHexColors = initialState
      .dailyReadingChecklistDescriptionItem
      .oldTestamentStructureStatus.map { $0.barHexColor }
    
    let newTestamentStructureHexColors = initialState
      .dailyReadingChecklistDescriptionItem
      .newTestamentStructureStatus.map { $0.barHexColor }
    
    let descriptionUpdateObservable = Observable.zip(
      fetchInitialStartDateAsObservable(),
      fetchContinuousChallengingDaysAsObservable(),
      fetchTotalReadChaptersAsObservable(),
      fetchMaxContinuousChallengingDaysAsObservable(),
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
        
        return Mutation.dailyReadingChecklistDescriptionFetched(
          .init(startDateStr: startDate,
                totalReadChapters: totalReadChapters,
                continuousChallengingDays: "\(days) 일",
                maxContinuousChallengingDays: "\(maximumContinuousDays) 일",
                oldTestamentStructureStatus: oldTestamentStructureStatus,
                newTestamentStructureStatus: newTestamentStructureStatus)
        )
      }
    return descriptionUpdateObservable
  }

  func fetchDailyReadingCehcklistBaseStream() -> Observable<Mutation> {
    fetchDailyReadingChecklistAsObservable().map { Mutation.dailyReadingChecklistCardFetched($0) }
  }
  
  /// 처음 받아오는 거라면 인디케이터없애고 화면 보여주기.
  /// 로딩 완료는 이제 리로드 후에 해주기
  /// 현재 개발적으로 특정 섹션만 리로드하는 로직 사용x.
  /// 그러나 처음에 lazy loading으로 이 섹션 fetch 하는 용도일 땐 사용.
  func fetchDailyReadingChecklistStream(forNewSection: Bool) -> Observable<Mutation> {
    if forNewSection {
      return Observable.concat([
        .just(.isLoadingForNewSectionSet(true)),
        fetchDescriptionItemStream(),
        fetchDailyReadingCehcklistBaseStream()
          .delay(.milliseconds(382), scheduler: MainScheduler.instance),
        .just(.dailyReadingChecklistCardFetchedCompletion(true)),
        .just(.dailyReadingChecklistCardFetchedCompletion(false)),
        .just(.isLoadingForNewSectionSet(false)).delay(.milliseconds(77), scheduler: MainScheduler.instance)
      ])
    }
    
    /// 개별적으로 업데이트
    return Observable.concat([
      fetchDailyReadingCehcklistBaseStream(),
      .just(.dailyReadingChecklistCardFetchedCompletion(true)),
      .just(.dailyReadingChecklistCardFetchedCompletion(false))
    ])
  }
}
