//
//  BibleMccCheyneChallengeReactor+BibleChallengeDataSource.swift
//  BibleReadingPlanFeature
//
//  Created by 양승현 on 3/17/25.
//

import RxSwift
import ReactorKit
import Foundation
import DomainEntity
import DesignSystemItems
import DesignSystemInterface

extension BibleMccCheyneChallengeReactor: BibleChallengeDataSource {
  public var hasInitiallyFetched: Bool {
    currentState.hasInitiallyFetched
  }
  
  public func challengeReferences(_ index: Int) -> [DomainEntity.BibleMccCheyneReference] {
    let specificChallengeBook = currentState.challengeEntity.sortedBookKeys()[index]
    return currentState.challengeEntity.rangeReferences(for: specificChallengeBook)
  }
  
  public var numberOfSectinos: Int {
    2
  }
  
  internal var numberOfDays: Int {
    bibleMccCheyneRepository.numberOfRecords
  }
  
  public var currentDayIndex: Int {
    return currentChallengeDay - 1
  }
  
  public var selectedDayIndex: Int {
    return selectedChallengeDay - 1
  }
  
  public func numberOfItems(_ section: Int) -> Int {
    if section == 0 {
      return bibleMccCheyneRepository.numberOfRecords
    } else {
      return 4
    }
  }
  
  /// 데이터를 다 저장하지 않고 여기서 즉석으로 만들자.
  /// currentDate는 .current
  /// 이전은 completion
  /// currentDate 후는 pending
  public func section(_ indexPath: IndexPath) -> BibleChallengeDayItem {
    let willDisplayDay = indexPath.item + 1
    let isSelectedDay = willDisplayDay == selectedChallengeDay
    let sectionState: BibleChallengeState
    
    if willDisplayDay == currentChallengeDay {
      sectionState = .current
    } else if willDisplayDay > currentChallengeDay {
      sectionState = .pending
    } else {
      sectionState = .completed
    }
    
    return BibleChallengeDayItem.init(state: sectionState, day: "\(willDisplayDay)", isSelected: isSelectedDay)
  }
  
  public func item(_ indexPath: IndexPath) -> BibleChallengeItem {
    let ref = currentState.challengeEntity.references[indexPath.item]
    let hasCompletedAll = isAllItemsCompleted()
    
    let _challenge = challenges[indexPath.item]
    
    return BibleChallengeItem(
      isOldTestament: ref.book.isOldTestament,
      challenges: _challenge,
      completed: ref.aleadyRead,
      hasCompletedAll: hasCompletedAll)
  }
  
  public func isAllItemsCompleted() -> Bool {
    currentState.challengeEntity.references.filter { $0.aleadyRead }.count >= 4
  }
  
  public func hasAlreadyShown(_ indexPath: IndexPath) -> Bool {
    return indexPath.item == (selectedChallengeDay - 1)
  }
}
