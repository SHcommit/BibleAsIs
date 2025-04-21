//
//  BibleReadingViewController+Helpers.swift
//  BibleContentFeature
//
//  Created by 양승현 on 3/17/25.
//

import UIKit
import DesignSystem

extension BibleReadingViewController {
  func handleUpdatedFont() {
    
    /// 폰트 변경 후 데이터 주입하는 데이터들은 폰트 변화가 업데이트 됬습니다.
    /// cellForRowAt시점 cell에 새롭게 업데이트 된 폰트를 넣어서 cell들의 높이가 동적으로 변화하게 됩니다.
    CATransaction.begin()
    if bibleReadingView.contentOffset != .zero {
      bibleReadingView.setContentOffset(.zero, animated: false)
    }
    UIView.setAnimationsEnabled(false)
    CATransaction.setCompletionBlock {
      UIView.setAnimationsEnabled(true)
    }
    
    bibleReadingView.reloadSections(IndexSet(integer: 0))
    CATransaction.commit()
  }
  
  func animateHidingScrollToTopView() {
    scrollToTopView.layer.removeAllAnimations()
    if scrollToTopView.alpha == 0 { return }
    let fadeOutAnim = CABasicAnimation(keyPath: "opacity").then {
      $0.fromValue = 1
      $0.toValue = 0
    }
    
    let transformAnim = CABasicAnimation(keyPath: "position.x").then {
      $0.fromValue = scrollToTopView.layer.position.x
      $0.toValue = scrollToTopView.layer.position.x + 7
      $0.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    }
    
    let animGroup = CAAnimationGroup().then {
      $0.duration = 0.7
      
      $0.animations = [fadeOutAnim, transformAnim]
    }
    scrollToTopView.layer.add(animGroup, forKey: "scrollFadeOutAnim")
    setScrollToTopView(alpha: 0)
  }
  
  // MARK: - Scroll
  func startScrollTracking() {
    scrollSaveTimer?.invalidate()
    guard scrollSaveTimer == nil else { return }
    setScrollSaveTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      let offsetY = bibleReadingView.contentOffset.y
      reactor?.action.onNext(.updatedOffset(
        offsetY: offsetY,
        contentSizeHeight: bibleReadingView.contentSize.height,
        visibleSizeHeight: bibleReadingView.bounds.height
      ))
    }
  }
  
  // MARK: - Sleep Timer Audio Play
  func deactiveAudioPlayFlow() {
    setPanGesture(isEnabled: true)
    showGradientView()
    updateFooterView()
    sleepTimerExecutingView.removeFromSuperview()
    delegate?.showNavigationMenuItem()
    releaseSleepTimerExecutingView()
    deactiveAudioPlay()
  }
  
  func deactiveAudioPlay() {
    if sleepAudioPlayer == nil { return }
    sleepAudioPlayer.releaseAllAudio()
    releaseSleepAudioPlayer()
  }
  
  // MARK: - Appearance
  func updateFooterView() {
    if let contentsControlView = bibleReadingView
      .visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter)
      .first(where: {$0 is BibleNewTestamentFooterReusableView }) as? BibleNewTestamentFooterReusableView {
      contentsControlView.configure(with: reactor?.fetchPageInfo())
    } else if let contentsControlView = bibleReadingView
      .visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter)
      .first(where: {$0 is BibleOldTestamentFooterReusableView }) as? BibleOldTestamentFooterReusableView {
      contentsControlView.configure(with: reactor?.fetchPageInfo())
    }
  }
  
  func prepareForStartingToSleepAudioPlay() {
    setPanGesture(isEnabled: false)
    delegate?.hideNavigationMenuItem()
    if sleepTimerExecutingView != nil { return }
    hideGradientView()
    initSleepTimerExecutingView()
    _=sleepTimerExecutingView.then {
      $0.setAutoLayout()
      $0.clearButtonTap = { [weak self] in
        guard let self else { return }
        sleepAudioPlayer.pause()
        reactor?.action.onNext(.sleepAudioCanceldByUser(elapsedSeconds: sleepAudioPlayer.elapsedSeconds))
      }
    }
    
    view.addSubview(sleepTimerExecutingView)
    NSLayoutConstraint.activate([
      sleepTimerExecutingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      sleepTimerExecutingView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      sleepTimerExecutingView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -14)
    ])
    sleepTimerExecutingView.fadeInFromBottom(initialOffsetY: 14)
    updateFooterView()
  }
  
  func prepareSleepAudioPlay() {
    dismiss(animated: true)
    prepareForStartingToSleepAudioPlay()
    setSleepAudioPlay()
  }
  
  func setSleepAudioPlay() {
    initSleepAudioPlayer()
    
    // MARK: 함수 일급객체로 주입하면 Retain cycle 발생됨. ( 받는 측에서 weak 클로저 프로퍼티 선언 안됨 )
    sleepAudioPlayer.prevChapterInvaild = { [weak self] elapsedSeconds in
      self?.handlePrevChapterInvaild(with: elapsedSeconds)
    }
    
    sleepAudioPlayer.specificBookHasAllCompleted = { [weak self] elapsedSeconds in
      self?.handleSpecificBookHasAllCompleted(with: elapsedSeconds)
    }
    
    sleepAudioPlayer.sleepTimerDidEnd = { [weak self] in
      self?.handleSleepTimerDidEnd()
      /// 시간지나면 핸드폰 잠기도록!
      UIApplication.shared.isIdleTimerDisabled = false
    }
    sleepAudioPlayer.onProgressUpdate = { [weak self] (remainingDuration) in
      guard let self else { return }
      let hours = Int(remainingDuration) / 3600
      let minutes = (Int(remainingDuration) % 3600) / 60
      let seconds = Int(remainingDuration) % 60
      
      var str: String = ""
      if hours > 0 {
        str = String(format: "%02d시간 %02d분 %02d초 후에 오디오가 종료됩니다!", hours, minutes, seconds)
      } else if minutes > 0 {
        str = String(format: "%02d분 %02d초 후에 오디오가 종료됩니다!", minutes, seconds)
      } else {
        str = String(format: "%02d초 후에 오디오가 종료됩니다!", seconds)
      }
      sleepTimerExecutingView.configure(with: str)
    }
  }
}
