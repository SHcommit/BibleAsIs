//
//  BibleReadingPaginationCoordinator.swift
//  BibleReadingFeature
//
//  Created by 양승현 on 3/25/25.
//

import UIKit
import Common
import Swinject
import DomainEntity
import SettingInterface
import DesignSystemItems
import BibleNoteInterface
import BibleReadingInterface

final class BibleReadingCoordinator: BibleReadingFlowDependencies {
  private weak var navigationController: UINavigationController?
  
  private var resolver: Swinject.Resolver
  
  private let isRestrictEntry: Bool
  
  private var updatedFontSizeHandler: ((CGFloat) -> Void)?
  
  private var ownerPickSleepTimeOptionHandler: ((SleepTimerOption) -> Void)?
  
  /// 노트 화면이 보여지면 이 플래그 활성화
  private var presentedBibleNotePageForWriting = false
  
  private var noteAddCompletion: ((BibleNote?) -> Void)?
  
  /// 노트 화면읽기가 보여지면 이 플래그 활성화
  private var presentedBibleNoteForReading = false
  
  private var noteDeletedCompletion: ((Bool) -> Void)?
  
  init(
    navigationController: UINavigationController? = nil,
    resolver: Swinject.Resolver,
    isRestrictEntry: Bool
  ) {
    self.isRestrictEntry = isRestrictEntry
    self.navigationController = navigationController
    self.resolver = resolver
  }
  
  public func makeViewController(
    currentReadingEntryItem startPageEntryItem: BibleReadingEntryItem,
    readingEntryItemsForRange: [BibleReadingEntryItem]
  ) -> UIViewController {
    let paginationController = BibleReadingPaginationController(
      currentReadingEntryItem: startPageEntryItem,
      bibleReadingEntryItemsForRange: readingEntryItemsForRange,
      isRestrictEntry: isRestrictEntry)
    
    return BibleReadingContainerViewController(
      paginationController: paginationController,
      flowDependencies: self)
  }
  
  func showBibleNotePageForWriting(
    bibleVerse: DomainEntity.BibleVerse,
    range: NSRange,
    noteAddCompletion: ((DomainEntity.BibleNote?) -> Void)?
  ) {
    guard let noteGateway = resolver.resolve(BibleNoteInterface.self) else {
      fatalError(.registrationErrorMsgByUnknownOuter(type: BibleNoteInterface.self))
    }
    self.noteAddCompletion = noteAddCompletion
    presentedBibleNotePageForWriting = true
    
    let noteViewController = noteGateway.makeNoteModule(
      navigationController: navigationController,
      resolver: resolver,
      coordinatorDelegate: self,
      bibleNote: nil,
      noteId: nil,
      noteRange: range,
      bibleVerse: bibleVerse)
    
    navigationController?.pushViewController(noteViewController, animated: true)
  }
  
  func showBibleNotePageForReading(
    bibleVerse: DomainEntity.BibleVerse,
    noteId: Int?,
    range: NSRange,
    noteDeleted: ((Bool) -> Void)?
  ) {
    guard let noteGateway = resolver.resolve(BibleNoteInterface.self) else {
      fatalError(.registrationErrorMsgByUnknownOuter(type: BibleNoteInterface.self))
    }
    
    presentedBibleNoteForReading = true
    self.noteDeletedCompletion = noteDeleted
    
    let noteViewController = noteGateway.makeNoteModule(
      navigationController: navigationController,
      resolver: resolver,
      coordinatorDelegate: self,
      bibleNote: nil,
      noteId: noteId,
      noteRange: range,
      bibleVerse: bibleVerse)
    
    navigationController?.pushViewController(noteViewController, animated: true)
  }
  
  func showSettingViewController(
    updatedFontSizeHandler: ((CGFloat) -> Void)?,
    ownerPickSleepTimeOptionHandler: ((SleepTimerOption) -> Void)?
  ) {
    guard let settingGateway = resolver.resolve(SettingInterface.self) else {
      fatalError(String.registrationErrorMsgByUnknownOuter(type: SettingInterface.self))
    }
    self.updatedFontSizeHandler = updatedFontSizeHandler
    self.ownerPickSleepTimeOptionHandler = ownerPickSleepTimeOptionHandler
    let settingViewController = settingGateway.makeSettingModule(
      navigationController: navigationController,
      resolver: resolver,
      delegate: self)
    
    navigationController?.present(settingViewController, animated: true)
  }
  
  func makeBibleReadingPage(
    currentReadingEntryItem: BibleReadingEntryItem,
    bibleReadingEntryItemsForRange: [BibleReadingEntryItem],
    entryBySleepAudioPlay: Bool,
    delegate: BibleReadingViewControllerDelegate?
  ) -> UIViewController {
    guard
      let readingViewController = resolver.resolve(
        UIViewController.self,
        name: BibleReadingViewController._identifier,
        arguments: self, entryBySleepAudioPlay, delegate,
        currentReadingEntryItem, bibleReadingEntryItemsForRange, isRestrictEntry
      ) as? BibleReadingViewController
    else { fatalError(String.registrationErrorMsgByInner(BibleReadingViewController.self)) }
    
    return readingViewController
  }
}

// MARK: - SettingCoordinatorDelegate
extension BibleReadingCoordinator: SettingCoordinatorDelegate {
  func handleOwnerPickSleepTimerOptionHandler(with option: SleepTimerOption) {
    ownerPickSleepTimeOptionHandler?(option)
  }
  
  func handleUpdatedFontSize(with fontSize: CGFloat) {
    updatedFontSizeHandler?(fontSize)
  }
}

// MARK: - BibleNoteCoordinatorDelegate
extension BibleReadingCoordinator: BibleNoteCoordinatorDelegate {
  /// 일단 노트 수정한 경우에, 이 readingPage에서는 알 여부가 아님.
  /// note highlighted Range를 노트 화면 내부에서 바꿀 수  없으니까.
  ///
  /// BibleReadingPage에서는 노트가 추가되었는지, 노트가 삭제되었는지.
  /// 노트가 수정되면 노트가 삭제 안된거니까 !
  /// BibleReadingPage 입장에서는 현 상태 유지!!
  func handleModifiedNote(
    modifiedNote: DomainEntity.BibleNote?,
    hasUserModifiedTheNote: Bool,
    hasUserDeletedTheNote: Bool
  ) {
    if presentedBibleNoteForReading {
      presentedBibleNoteForReading = false
      // 읽기 목적임.
      if hasUserDeletedTheNote {
        noteDeletedCompletion?(true)
      } else {
        noteDeletedCompletion?(false)
      }
      
    } else if presentedBibleNotePageForWriting {
      presentedBibleNotePageForWriting = false
      if modifiedNote != nil {
        noteAddCompletion?(modifiedNote)
      }
    }
  }
}
