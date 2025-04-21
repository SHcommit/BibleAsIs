//
//  BibleMccCheyneChallengeReactor+Challenge.swift
//  BibleReadingPlanFeature
//
//  Created by 양승현 on 3/17/25.
//

import RxSwift
import ReactorKit
import Foundation
import DomainEntity

extension BibleMccCheyneChallengeReactor {
  func fetchSpecificChallengeStream(with day: Int) -> Observable<Mutation> {
    return fetchSpecificChallengeEntry(with: day)
      .map { .mccCheyneChallengeEntrySet($0) }
  }
  
  /// day에 따라서 entry를 받아옴
  func fetchSpecificChallengeEntry(with day: Int) -> Observable<DailyMccCheyneEntity> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      
      bibleMccCheyneRepository.fetchDailyReadingPlan(forDay: day) { result in
        switch result {
        case .success(let entry):
          if let entry {
            observer.onNext(entry)
            observer.onCompleted()
          } else {
            observer.onError(CommonError.referenceDeallocated)
          }
        case .failure(let failure):
          observer.onError(failure)
        }
      }
      return Disposables.create()
    }
  }
  
  /// 모든 체크박스가 완료되었을 때
  func updateCurrentChallengeDayByCompletingAllChallengesStream() -> Observable<Mutation> {
    let nextDay = currentChallengeDay + 1
    if nextDay >= numberOfDays {
      return Observable.concat([
        .just(.currentDayUpdatedByCompletingAllChallenges(false)),
        .just(.currentDayUpdatedByCompletingAllChallenges(nil))
      ])
    }
    
    /// 다음 장 가기 위해서, 준비하는 단계
    /// 1. 그 사용자 cur challenge day 를 저장소에 업뎃
    /// 2. 관련 새로운 day challenge entry 받고 newState
    /// 3. currentDayUdaptedByCompletionAllChallenges(true) 고고링~
    return updateCurrentChallengeDayAsObservable(nextDay)
      .flatMap { [weak self] _ -> Observable<Mutation> in
        guard let self else {
          return .just(.unexpectedErrorOccured(CommonError.referenceDeallocated.localizedDescription))
        }
        
        let fetchNewEntryStream = fetchSpecificChallengeStream(with: nextDay)
        let lastStreamForEffectingNextDayMovement = Observable.just(
          Mutation.currentDayUpdatedByCompletingAllChallenges(true))
        
        return Observable.concat([
          .just(Mutation.currentDaySet(.init(currentDay: nextDay))),
          .just(Mutation.selectedDaySet(nextDay)),
          fetchNewEntryStream,
          lastStreamForEffectingNextDayMovement,
          .just(Mutation.currentDayUpdatedByCompletingAllChallenges(nil))
        ])
      }
  }
  
  /// flatMap써야하니까,, Reuslt -> 옵저버블로 반환.
  /// 모든 체크박스 체크되서 다음 챌린지로 업데이트 하기 위해 로컬에 다음 챌린지 day 저장하는 로직
  func updateCurrentChallengeDayAsObservable(_ day: Int) -> Observable<Void> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      ownerMccCheyneRepository.updateCurrentChallengeDay(day) { result in
        switch result {
        case .success:
          observer.onNext(())
          observer.onCompleted()
        case .failure(let failure):
          observer.onError(failure)
        }
      }
      return Disposables.create()
    }
  }
  
  /// 로컬에서 현재 사용자의 Challeging Day를 가져옵니다.
  func fetchCurrentMccCheyneChallengeDayStream() -> Observable<Mutation> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      
      ownerMccCheyneRepository.fetchCurrentChallengeDay { result in
        switch result {
        case .success(let recentMccCheyneDay):
          observer.onNext(.currentDaySet(recentMccCheyneDay))
          observer.onCompleted()
        case .failure(let failure):
          observer.onError(failure)
        }
      }
      
      return Disposables.create()
    }
  }
  
  /// 특정 체크박스 클릭 후 해당 바이블 읽기를 완료했는지 여부 업데이트
  func updateChallengeEntryStream(
    challenge indexPath: IndexPath,
    hasRead: Bool
  ) -> Observable<Mutation> {
    guard indexPath.section == 1 else { return .just(.none) }
    if currentChallengeDay != selectedChallengeDay { return .just(.none) }
    var newChallengeEntity = currentState.challengeEntity
    newChallengeEntity.references[indexPath.item].aleadyRead = hasRead
    
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      
      /// true 면 성공 false면 실패
      bibleMccCheyneRepository.updateDailyReadingPlan(
        forDay: currentChallengeDay,
        entry: newChallengeEntity, completion: { result in
          switch result {
          case .success(let succeed):
            if succeed {
              observer.onNext(.mccCheyneChallengeEntrySet(newChallengeEntity))
            } else {
              observer.onNext(.unexpectedErrorOccured("예기치 못한 에러로 체크박스 완료를 할 수 없습니다."))
            }
            observer.onCompleted()
          case .failure(let failure):
            observer.onError(failure)
          }
        })
      return Disposables.create()
    }
  }
}
