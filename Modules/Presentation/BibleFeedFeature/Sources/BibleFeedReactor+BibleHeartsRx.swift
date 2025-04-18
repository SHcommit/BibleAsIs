//
//  BibleFeedReactor+BibleHeartsRx.swift
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
  private func fetchHeartVersesAsObservable() -> Observable<[BibleVerse]> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      
      bibleHeartFetchUseCase.fetchAllLikedVerses { result in
        switch result {
        case .success((_, let verses)):
          let maximumCount = verses.count >= 3 ? 3 : verses.count
          if verses.isEmpty {
            observer.onNext([])
          } else {
            observer.onNext((0..<maximumCount).map { verses[$0] })
          }
          observer.onCompleted()
        case .failure(let error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
  
  // MARK: - Stream
  func fetchHeartVersesBaseStream() -> Observable<Mutation> {
    fetchHeartVersesAsObservable().map { Mutation.bibleHeartVersesFetched($0) }
  }
  
  /// 현재 개발적으로 특정 섹션만 리로드하는 로직 사용x.
  /// 그러나 처음에 lazy loading으로 이 섹션 fetch 하는 용도일 땐 사용.
  func fetchHeartVersesStream(forNewSection: Bool) -> Observable<Mutation> {
    /// 로딩 완료는 이제 리로드 후에 해주기
    if forNewSection {
      return Observable.concat([
        .just(.isLoadingForNewSectionSet(true)),
        fetchHeartVersesBaseStream()
          .delay(.milliseconds(Int.random(in: 300...470)), scheduler: MainScheduler.instance),
        .just(Mutation.bibleHeartVersesFetchedCompletion(true)),
        .just(Mutation.bibleHeartVersesFetchedCompletion(false)),
        .just(.isLoadingForNewSectionSet(false)).delay(.milliseconds(77), scheduler: MainScheduler.instance)
      ])
    }
  
    return Observable.concat([
      fetchHeartVersesBaseStream(),
      .just(Mutation.bibleHeartVersesFetchedCompletion(true)),
      .just(Mutation.bibleHeartVersesFetchedCompletion(false))
    ])
  }
}
