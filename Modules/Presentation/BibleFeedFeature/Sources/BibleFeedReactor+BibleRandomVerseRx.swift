//
//  BibleFeedReactor+BibleRandomVerseRx.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 3/19/25.
//

import RxSwift
import ReactorKit
import Foundation
import DomainEntity

extension BibleFeedReactor {
  // MARK: - AsObservable
  private func fetchWeeklyRandomVersesAsObservable(fromDay: Int) -> Observable<[[BibleVerse]]> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      
      randomVerseFetchUseCase.fetchWeeklyRandomVerses(fromDay: fromDay) { result in
        switch result {
        case .success(let versesArray):
          observer.onNext(versesArray)
          observer.onCompleted()
        case .failure(let error):
          observer.onError(error)
        }
      }
      
      return Disposables.create()
    }
  }
  
  // MARK: - Stream
  func fetchWeeklyRandomVersesBaseStream(fromDay: Int) -> Observable<Mutation> {
    return fetchWeeklyRandomVersesAsObservable(fromDay: fromDay)
      .map { Mutation.weeklyRandomVersesFetched($0) }
  }
  
  // MARK: Notes
  /// "주간 랜덤 섹션만 업데이트 할 경우 사용됨. 현재 개별 섹션만 따로 리로드하는 방식은 미사용"
  func fetchWeeklyRandomVersesStream(fromDay: Int) -> Observable<Mutation> {
    return Observable.concat([
      fetchWeeklyRandomVersesBaseStream(fromDay: fromDay),
      .just(.weeklyRandomVersesFetchedCompletion(true)),
      .just(.weeklyRandomVersesFetchedCompletion(false))
    ])
  }
}
