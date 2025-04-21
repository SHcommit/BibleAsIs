//
//  BibleReadingChecklistReactor+DateStream.swift
//  BibleReadingChecklistFeature
//
//  Created by 양승현 on 3/23/25.
//

import RxSwift
import ReactorKit
import Foundation
import DomainEntity

// MARK: - Default daily reading checklist description
extension BibleReadingChecklistReactor {
  func fetchInitialStartDateStream() -> Observable<String> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      bibleReadingPlanUseCase.fetchStartDate { [weak self] result in
        guard let self else {
          observer.onError(CommonError.referenceDeallocated)
          return
        }
        switch result {
        case .success(let date):
          var convertedInitialStartDateString = "미정"
          if let date = date {
            convertedInitialStartDateString = "\(dateController.convertYYMMDDString(from: date))"
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
  
  func fetchContinuousChallengingDaysStream() -> Observable<Int> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      bibleReadingPlanUseCase.fetchContinuousChallengingDays { result in
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
  
  func fetchMaxContinuousChallengingDaysStream() -> Observable<Int> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      bibleReadingPlanUseCase.fetchMaxContinuousChallengingDays { result in
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
}
