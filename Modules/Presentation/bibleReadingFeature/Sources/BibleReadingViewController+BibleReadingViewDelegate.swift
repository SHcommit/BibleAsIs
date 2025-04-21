//
//  BibleReadingViewController+BibleReadingViewDelegate.swift
//  BibleContentFeature
//
//  Created by 양승현 on 3/17/25.
//

import UIKit
import DomainEntity
import DesignSystem
import DesignSystemItems
import DesignSystemInterface

extension BibleReadingViewController: BibleReadingViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) { }
  
  public func willDisplayTitleHeaderView() {
    delegate?.willDisplayTitleHeaderView(reactor?.currentState.bookChapterVerseName)
    animateHidingScrollToTopView()
    
  }
  
  public func disappearTitleHeaderView() {
    delegate?.disappearTitleHeaderView()
    if scrollToTopView.alpha == 1 { return }
    scrollToTopView.layer.removeAllAnimations()
    scrollToTopView.animateFadeInWithSmoothBounce(
      direction: .horizontal,
      delay: 0.0,
      duration: 1.2,
      damping: 5,
      mass: 0.2,
      initialVelocity: 1,
      stifness: 127)
  }
  
  public func updateIndicatorWidth(_ width: CGFloat) {
    bibleReadingView.updateScrollIndicator(width)
  }
  
  public func readCompletionThisChapter() {
    reactor?.action.onNext(.readCompleted)
  }
  
  public func showPrevChapter(bySleepTimer: Bool = false) {
    delegate?.handlePrevPageShowing(bySleepTimer)
  }
  
  public func showNextChapter(bySleepTimer: Bool = false) {
    delegate?.handleNextPageShowing(bySleepTimer)
  }
  
  public func tapHeart(_ cell: UICollectionViewCell) {
    //  guard let indexPath = bibleReadingView.indexPath(for: cell) else { return }
    // 특정 하트 isOn false하도록 데이터 수정은 안하도록!
  }
  
  public func showColorPickerAlert(
    _ cell: UICollectionViewCell,
    range: NSRange,
    withAlert alert: UIAlertController
  ) {
    if bibleReadingView.indexPath(for: cell) == nil { return }
    present(alert, animated: true)
  }
  
  public func toggleHeart(
    _ cell: UICollectionViewCell,
    isOnHeart: Bool
  ) {
    guard let indexPath = bibleReadingView.indexPath(for: cell) else { return }
    reactor?.action.onNext(.heartToggle(index: indexPath.item, isOnHeart: isOnHeart))
  }
  
  // MARK: - Highlight
  public func addColor(
    _ cell: UICollectionViewCell,
    range: NSRange,
    colorIndex: HighlightColorIndex,
    completion: @escaping (BibleVerseHighlightItem) -> Void
  ) {
    guard let indexPath = bibleReadingView.indexPath(for: cell) else { return }
    print("색 추가 : \(indexPath), colorIndex: \(colorIndex), range: \(range)")
    setColorAddCompletion(completion)
    reactor?.action.onNext(.highlightAppend(
      index: indexPath.item, range: range, colorIndex: colorIndex))
  }
  
  public func deleteHighlight(_ cell: UICollectionViewCell, id: Int) {
    guard let indexPath = bibleReadingView.indexPath(for: cell) else { return }
    reactor?.action.onNext(.highlightDelete(index: indexPath.item, id: id))
  }
  
  // MARK: - Note
  public func addNote(_ cell: UICollectionViewCell, range: NSRange) {
    guard let indexPath = bibleReadingView.indexPath(for: cell) else { return }
    guard let item = reactor?.currentState.bibleVerses[indexPath.item] else {
      ToastController.shared.showToast(message: "추가한 노트를 저장하지 못했습니다", type: .error)
      assertionFailure("확인하려는 verse 아이템 정보가 없음."); return
    }
    
    let verse = BibleVerse(reference: item.reference, content: item.verseContent)
    setViewWillAppearBySettingOrNoteView(true)
    flowDependencies?.showBibleNotePageForWriting(
      bibleVerse: verse, range: range,
      noteAddCompletion: { [weak self] bibleNote in
        guard let bibleNote else { print("저장 안한거 그러니까 글 안쓴거임."); return }
        self?.reactor?.action.onNext(.noteAppend(index: indexPath.item, bibleNote: bibleNote))
      })
  }
  
  public func tapNote(_ cell: UICollectionViewCell) {
    guard let indexPath = bibleReadingView.indexPath(for: cell) else { return }
    guard let item = reactor?.currentState.bibleVerses[indexPath.item], let range = item.note?.range else {
      ToastController.shared.showToast(message: "노트 id를 식별할 수 없어 노트 실행이 불가능합니다.", type: .error)
      return
    }
    
    let bibleVerse = BibleVerse(reference: item.reference, content: item.verseContent)
    setViewWillAppearBySettingOrNoteView(true)
    flowDependencies?.showBibleNotePageForReading(
      bibleVerse: bibleVerse,
      noteId: item.note?.noteId,
      range: range,
      noteDeleted: { [weak self] noteDeleted in
        guard noteDeleted else { return }
        self?.reactor?.action.onNext(.noteRemove(index: indexPath.item))
      })
  }
  
  public func deleteNote(_ cell: UICollectionViewCell) {
    guard let indexPath = bibleReadingView.indexPath(for: cell) else { return }
    reactor?.action.onNext(.noteRemove(index: indexPath.item))
  }
}
