//
//  BibleNoteViewControllerDelegate.swift
//  bibleNoteInterface
//
//  Created by 양승현 on 3/26/25.
//

import Foundation
import DomainEntity

public protocol BibleNoteViewControllerDelegate {
  /// 여기선 뒤로갈 때 modifiedNoteIndex가 없으면 아무런 수행을 안한것임 지극히 자연스러운 로직이다. 이말인거야!
  /// - Note 1 :노트 화면이 사라지면 이 함수가 호출됩니다.
  ///
  /// 노트가 수정되거나, 저장됬다면 실제 값 반환, 그게 아닐 경우 nil 반환함.
  /// 수정된 경우에는 화면 맨 위로! ( date에 따라 자동 정렬 하도록 sqlite3 오더바이 쿼리 짰음 )
  /// 노트가 삭제되면 hasDeleted true
  func handleModifiedNote(modifiedNote: BibleNote?, hasUserModifiedTheNote: Bool, hasUserDeletedTheNote: Bool)
}
