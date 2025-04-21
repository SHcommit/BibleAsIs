//
//  BibleFeedReactor+BibleNotesDataSource.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 3/22/25.
//

import Foundation
import DomainEntity

extension BibleFeedReactor: BibleFeedAdapterBibleNotesDataSource {
  public var isNotesEmpty: Bool {
    currentState.bibleNoteReferences.isEmpty
  }
  
  public func fetchBibleNoteVerse(indexPath: IndexPath) -> BibleVerse? {
    let index = indexPath.row
    if index >= currentState.bibleNoteVerses.count {
      assertionFailure(
        "디비 query offset 3, page 1고정했고, verses를 reactor에서도 받아올때 3이내로 필터링함. 뭐가문제지? 컬스택 확인바람")
      return nil
    }
    return currentState.bibleNoteVerses[index]
  }
  
  public func bibleNotesHeaderItem() -> String? {
    "바이블 노트"
  }
}
