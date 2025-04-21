//
//  BibleMccCheyneChallengeViewController+BibleChallengeDelegate.swift
//  BibleReadingPlanFeature
//
//  Created by 양승현 on 3/17/25.
//

import RxSwift
import ReactorKit
import Foundation
import DesignSystem
import DesignSystemInterface

extension BibleMccCheyneChallengeViewController: BibleChallengeDelegate {
  public func prepareToMoveNextDay() {
    reactor?.action.onNext(.NextDayChallengeMovePrepare)
  }
  
  public func updateSelectedDay(_ indexPath: IndexPath) {
    /// 이미 보여진거 탭하면 다시 디비에서 불러와야하니까 무쓸모!
    if reactor?.hasAlreadyShown(indexPath) == true { return }
    reactor?.action.onNext(.selectionDayUpdate(indexPath: indexPath))
  }
  
  /// checkbox 선택할 때마다 호출 함
  public func update(specificDailyChallenge indexPath: IndexPath, readCompleted completed: Bool) {
    view.툭()
    reactor?.action.onNext(.update(specificDailyChallenge: indexPath, readCompleted: completed))
  }
  
  public func didTapBibleChallenge(_ index: Int) {
    guard let references = reactor?.challengeReferences(index), !references.isEmpty else {
      ToastController.shared.showToast(message: "시스템 오류로 첼린지 식별자를 확인 할 수 없습니다.\n다시 시도해주세요.", type: .warning)
      return
    }
    flowDependencies.showRestrictedRangeBasedBibleReadingPage(references: references)
  }
}
