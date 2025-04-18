//
//  BibleReadingReactor+Heart.swift
//  BibleContentFeature
//
//  Created by 양승현 on 3/17/25.
//

import RxSwift
import ReactorKit
import Foundation
import DomainEntity

extension BibleReadingReactor {
  // MARK: - AsObservable
  func makeHeartStatusFetchObservable(for verseId: Int) -> Observable<Bool> {
    return Observable<Bool>.create { [weak self] heartObserver  in
      guard let self else {
        heartObserver.onError(CommonError.referenceDeallocated)
        return Disposables.create()
      }
      bibleRepository.fetchHeartStatus(for: verseId) { result in
        switch result {
        case .success(let heart):
          heartObserver.onNext(heart)
          heartObserver.onCompleted()
        case .failure(let error):
          heartObserver.onError(error)
        }
      }
      return Disposables.create()
    }
  }
  
  func toggleHeartStatusAsObservable(for verseId: Int, isOnHeart: Bool) -> Observable<Void> {
    return Observable<Void>.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      bibleRepository.toggleHeartStatus(for: verseId, isOnHeart: isOnHeart) { result in
        switch result {
        case .success:
          observer.onNext(())
          observer.onCompleted()
        case .failure(let error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
  
  // MARK: - Stream
  func toggleHeartStatusStream(with index: Int, isOnHeart: Bool) -> Observable<Mutation> {
    let verseId = currentState.bibleVerses[index].verseId
    return toggleHeartStatusAsObservable(for: verseId, isOnHeart: isOnHeart)
      .map {
        Mutation.heartToggle(
          index: index,
          isOnHeart: isOnHeart)
      }
  }
}
