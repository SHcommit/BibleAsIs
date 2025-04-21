//
//  BibleHomeViewController+Helpers.swift
//  BibleHomeFeature
//
//  Created by 양승현 on 3/25/25.
//

import UIKit
import DesignSystem
import DesignSystemItems

extension BibleHomeViewController {
  // MARK: - Helpers
  func configCarousel() {
    let dataSource: [HorizontalVerseCarouselCellItem] = [
      .init(
        backgroundImage: DesignSystemAsset.Image.backgroundImage1.image,
        verse: "\"구하라 그리하면 너희에게 주실 것이요 찾으라 그리하면 찾아낼 것이요 문을 두드리라 그리하면 너희에게 열릴 것이니\"",
        bookName_chapterVerse: "마태복음 7:7"),
      .init(
        backgroundImage: DesignSystemAsset.Image.backgroundImage2.image,
        verse: "\"오직 여호와를 앙망하는 자는 새 힘을 얻으리니 독수리가 날개치며 올라감을 같을 것이요 달음박질하여도 곤비하지 아니하겠고 걸어가도 피곤하지 아니하리로다\"",
        bookName_chapterVerse: "마태복음 7:7"),
      .init(
        backgroundImage: DesignSystemAsset.Image.backgroundImage3.image,
        verse: "\"은을 구하는 것 같이 그것을 구하며 감추어진 보배를 찾는 것 같이 그것을 찾으면 여호와 경외하기를 깨달으며 하나님을 알게 되리니\"",
        bookName_chapterVerse: "잠언 2:4-5")]
    carouselView.configure(dataSource)
  }
  
  func showOldTestamentBooks() {
    if !isExpanded {
      isExpandedUpdate(with: true)
      NSLayoutConstraint.deactivate(defaultConstraints)
      NSLayoutConstraint.activate(expandedConstraints)
      UIView.animate(
        withDuration: 0.7, delay: 0,
        usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7,
        animations: {
          self.view.layoutIfNeeded()
        })
    }
    oldTestamentTagsShow?()
  }
  
  func showNewTestamentBooks() {
    if !isExpanded {
      isExpandedUpdate(with: true)
      NSLayoutConstraint.deactivate(defaultConstraints)
      NSLayoutConstraint.activate(expandedConstraints)
      UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, animations: {
        self.view.layoutIfNeeded()
      })
    }
    newTestamentTagsShow?()
  }
}
