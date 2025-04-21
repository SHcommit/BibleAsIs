//
//  BibleFeedFlowDependencies.swift
//  BibleFeedInterface
//
//  Created by 양승현 on 3/28/25.
//

import UIKit
import DomainEntity
import DesignSystemItems

public protocol BibleFeedFlowDependencies {
  func makeViewController() -> UIViewController
  
  func makeMccCheynechallengeViewController() -> UIViewController
  
  func showBibleHeartHistoryPage()
  
  func showBibleNoteHomePage(entryWithNote: BibleNote?, andEntryVerseforNote: BibleVerse?)
  
  func showBibleReadingChecklistPage() 
  
  func showBibleReadingPageForRecentReadVerses(with bookclipItem: RecentReadBibleBookclipItem)
  
  func showBibleGardenYearSelectionPage(withUserSelectionYear: Int, completion: @escaping (Int) -> Void)
  
  func showFeedSettingPage()
}
