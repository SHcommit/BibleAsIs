//
//  BibleHomeViewController+BibleHomeViewAdapterDelegate.swift
//  BibleHomeFeature
//
//  Created by 양승현 on 3/25/25.
//

import UIKit
import ReactorKit
import DomainEntity
import DesignSystem
import DesignSystemInterface

// MARK: - BibleHomeViewAdapterDelegate
extension BibleHomeViewController: BibleHomeViewAdapterDelegate {
  public func tapOldTestamentBible() {
    reactor?.action.onNext(.oldTestamentBooksShow)
  }
  
  public func tapNewTestamentBible() {
    reactor?.action.onNext(.newTestamentBooksShow)
  }
  
  public func tapOldTestamentBook(_ indexPath: IndexPath) {
    reactor?.action.onNext(.oldTestamentsCategoryTap(indexPath))
  }
  
  public func tapNewTestamentBook(_ indexPath: IndexPath) {
    reactor?.action.onNext(.newTestamentsCategoryTap(indexPath))
  }
  
  public func tapChapter(indexPath: IndexPath, chapterNumber: Int) {
    guard let testament = BibleTestament(rawValue: indexPath.section) else {
      ToastController.shared.showToast(message: "잘못된 bible testament 정보가 담겨서 실패했습니다. 다시 시도해주세요", type: .error)
      return
    }
    var book: BibleBook
    if testament == .old {
      book = BibleBook.oldTestaments[indexPath.row]
    } else {
      book = BibleBook.newTestaments[indexPath.row]
    }
    
    flowDependencies.showBibleReadingPage(testament: testament, book: book, chapter: chapterNumber)
  }
}
