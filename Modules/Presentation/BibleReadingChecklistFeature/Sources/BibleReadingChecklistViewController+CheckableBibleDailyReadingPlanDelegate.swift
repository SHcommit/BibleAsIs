//
//  BibleReadingChecklistViewController+CheckableBibleDailyReadingPlanDelegate.swift
//  BibleReadingChecklistFeature
//
//  Created by 양승현 on 3/27/25.
//

import UIKit
import RxSwift
import ReactorKit
import DesignSystem
import DesignSystemInterface

extension BibleReadingChecklistViewController: CheckableBibleDailyReadingPlanDelegate {
  /// 챕터 탭 굿.
  ///
  /// 문제를 찾아냄. 이게 희안하게 ㅋㅋㅋ
  /// 너무 빠르게 모든 챕터들을 동시에 눌러대면 어던거는 이거 indexPath를 못찾는다고 나옴. 그럼에도 실행은됨. 뭔가 중복 터치 방지는 되고 결국에 내가 생가한
  /// 모든 로직은 동작하는데 가끔가다가 ToastController가 호출된다는거지. 너무빠르게 다른것들을 거의 연속으로 챕터들을 누를 경우에
  public func didTapChapterForReadingMark(
    _ testamentCell: UITableViewCell,
    chapterIndex: Int
  ) {
    guard let indexPath = checkableDailyReadingView.indexPath(for: testamentCell) else {
      ToastController.shared.showToast(message: "시스템 오류로 인해 해당 챕터의 인덱스를 찾을 수 없습니다.\n잠시후에 다시 시도해주세요.", type: .error)
      return
    }
    reactor?.action.onNext(.toggableChapterReadTap(indexPath, chapterIndex))
  }
  
  public func didLongPressedForChapter(
    _ testamentCell: UITableViewCell,
    chapterIndex: Int,
    alert: UIAlertController
  ) {
    flowDependencies.showDatePickerAlert(alert)
  }
  
  /// 여기서는 무저건 ! alreadyRead가 펄스라면 트루로!
  public func didSelectedDateForChapter(
    _ testamentCell: UITableViewCell,
    chapterIndex: Int,
    selectedDate: String
  ) {
    guard let indexPath = checkableDailyReadingView.indexPath(for: testamentCell) else {
      assertionFailure("Accordion 헤더 뷰 를 클릭했지만 해당 cell의 indexPath를 찾을 수 없음")
      return
    }
    print("데이트 픽. DP라 부를까? : \(selectedDate)")
    reactor?.action.onNext(.readDateSelect(indexPath, chapterIndex, selectedDate))
  }
  
  public func didTapBibleBookHeaderView(_ testamentCell: UITableViewCell) {
    guard let indexPath = checkableDailyReadingView.indexPath(for: testamentCell) else {
      assertionFailure("Accordion 헤더 뷰 를 클릭했지만 해당 cell의 indexPath를 찾을 수 없음")
      return
    }
    reactor?.action.onNext(.specificTestamentOfBookTap(indexPath))
  }
  
  public func didScroll(offsetY: CGFloat) {
    
    if offsetY < 0 {
      setShouldCardHeaderExpand(with: true)
      guard let header = checkableDailyReadingView
        .headerView(forSection: 0) as? ExpandedBibleReadingChecklistHeaderView else { return }
      header.cardViewTopConstraint.isActive = false
      header.cardViewTopConstraint.constant = offsetY
      header.cardViewTopConstraint.isActive = true
    } else if offsetY >= 0 {
      guard let header = checkableDailyReadingView
        .headerView(forSection: 0) as? ExpandedBibleReadingChecklistHeaderView else { return }
      if shouldCardHeaderExpand {
        setShouldCardHeaderExpand(with: false)
        header.cardViewTopConstraint.isActive = false
        header.cardViewTopConstraint.constant = offsetY
        header.cardViewTopConstraint.isActive = true
      }
    }
    
    if shouldCardHeaderExpand {
      guard let header = checkableDailyReadingView
        .headerView(forSection: 0) as? ExpandedBibleReadingChecklistHeaderView else { return }
      header.cardViewTopConstraint.isActive = false
      header.cardViewTopConstraint.constant = offsetY
      header.cardViewTopConstraint.isActive = true
    }
    
    let maxOffset: CGFloat = 44
    let alpha = min(1.0, max(0, offsetY / maxOffset))
    if offsetY >= 44 {
      if !isBlurVisible {
        setBlurIsVisible(true)
        setNavigationViewBlurAlpha(1)
      }
    } else {
      setBlurIsVisible(false)
      setNavigationViewBlurAlpha(alpha)
    }
    
    let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    
    if offsetY >= 284 - 44 - statusBarHeight {
      if !hasDailyCardHeaderViewDisappeared {
        setDailyCardHeaderViewHasDisappeared(true)
        handleCardHeaderViewDisappear()
      }
    } else {
      if hasDailyCardHeaderViewDisappeared {
        setDailyCardHeaderViewHasDisappeared(false)
        handleCardHeaderViewWillDisplay()
      }
    }
  }
}
