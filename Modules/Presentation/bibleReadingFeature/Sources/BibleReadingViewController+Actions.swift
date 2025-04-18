//
//  BibleContentViewController+Actions.swift
//  BibleContentFeature
//
//  Created by 양승현 on 3/13/25.
//

import UIKit
import DesignSystem
import DomainEntity

extension BibleReadingViewController {
  @objc func didTapScrollToTopView() {
    bibleReadingView.setContentOffset(.zero, animated: true)
  }
  
  @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
    let velocity = gesture.velocity(in: view)
    
    /// 이렇게 일전 가속도 기준을 잡아두는 이유는,
    /// 하이라이트, 노트 등 또한 long gesture + 드래그로 이루어짐
    /// velocity없이 그냥 바로 x += 0 기준으로 해버린다면 별로임
    if gesture.state == .ended {
      if velocity.x > 77 {
        showPrevChapter()
      } else if velocity.x < -77 {
        showNextChapter()
      }
    }
  }
  
  /// 이전 장으로 돌아가자. 현재까지 진행했던 시간은 저장하고. ( 현재까지 진행한거 모두 반영헤서 래포에 저장하고
  /// 지금까지 진행된 시간을 받음. 그러니까. 디비에 저장된걸 받아서, 거기서 저장된 현재 진행시간과 지금 또 진행했던 시간을 더해서 저장하면됨.
  /// 매번 시작할때 타임이 만료됬는지 체크함.
  func handlePrevChapterInvaild(with elapsedSeconds: TimeInterval) {
    reactor?.action.onNext(.sleepAudioPalyElapsedSecondsSave(elapsedSeconds: elapsedSeconds, andPlayPrevChapter: true))
  }
  
  /// 다음 장으로 가자. 현재까지 진행했던 모든 시간은 저장하고.
  /// 지금까지 진행된 시간을 받음. 그러니까. 디비에 저장된걸 받아서, 거기서 저장된 현재 진행시간과 지금 또 진행했던 시간을 더해서 저장하면됨.
  func handleSpecificBookHasAllCompleted(with elapsedSeconds: TimeInterval) {
    reactor?.action.onNext(.sleepAudioPalyElapsedSecondsSave(elapsedSeconds: elapsedSeconds, andPlayPrevChapter: false))
  }
  
  /// 레포에 저장해서 끝났음을 저장하자
  func handleSleepTimerDidEnd() {
    reactor?.action.onNext(.sleepAudioCanceldByUser(elapsedSeconds: 0))
    ToastController.shared.showToast(message: "지정된 시간이 모두 지나 오디오가 종료됩니다", type: .success)
  }
  
  public func handleUpdatedFont(_ fontSize: CGFloat) {
    reactor?.action.onNext(.fontUpdated(fontSize))
  }
  
  public func handleOwnerPickSleepTimeOption(_ option: SleepTimerOption) {
    reactor?.action.onNext(.sleepAudioIsPicked(option))
  }
}
