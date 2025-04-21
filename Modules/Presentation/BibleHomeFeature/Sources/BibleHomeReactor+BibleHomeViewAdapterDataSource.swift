//
//  BibleHomeReactor+BibleHomeViewAdapterDataSource.swift
//  BibleHomeFeature
//
//  Created by 양승현 on 3/25/25.
//

import Foundation
import ReactorKit
import DomainEntity
import DesignSystemItems
import DesignSystemInterface

// MARK: - BibleHomeViewAdapterDataSource
extension BibleHomeReactor: BibleHomeViewAdapterDataSource {
  public var hasInitiallyFetched: Bool {
    currentState.hasInitiallyFetched
  }
  
  public var numberOfSections: Int { 2 }
  
  public var oldTestamentExpended: Bool {
    return currentState.oldTestamentExpanded
  }
  
  public var newTestamentExpended: Bool {
    return currentState.newTestamentExpanded
  }
  
  public func item(_ indexPath: IndexPath) -> BibleHomeItem? {
    guard let testament = BibleTestament(rawValue: indexPath.section) else { return nil }
    if testament == .old {
      return currentState.oldTestamentItems[indexPath.item]
    } else {
      return currentState.newTestamentItems[indexPath.item]
    }
  }
  
  public func headerItem(_ section: BibleTestament) -> BibleTestamentAccordionHeaderItem {
    let currentClip = recentBibleBookclipRepository.fetchRecentClip()
    let isClippedOldTestament = currentClip.testament == .old ? true : false
    if section == .old {
      return BibleTestamentAccordionHeaderItem(type: .old, title: "구약 성경", isClipped: isClippedOldTestament)
    } else {
      return BibleTestamentAccordionHeaderItem(type: .new, title: "신약 성경", isClipped: !isClippedOldTestament)
    }
  }
  
  public func numberOfItems(_ section: Int) -> Int {
    guard let testament = BibleTestament(rawValue: section) else { return 0 }
    if testament == .old {
      return BibleBook.oldTestaments.count
    } else {
      return BibleBook.newTestaments.count
    }
  }
}
