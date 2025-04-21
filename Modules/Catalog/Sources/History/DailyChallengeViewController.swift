//
//  DailyChallengeViewController.swift
//  JourneyOfFaithCatalogApp
//
//  Created by 양승현 on 1/27/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import Then
import DomainEntity
import DesignSystem
import DesignSystemItems
import DesignSystemInterface

class DailyChallengeDataSourceProvider: BibleChallengeDataSource {
  var hasInitiallyFetched: Bool = true
  
  func challengeReferences(_ index: Int) -> [BibleMccCheyneReference] {
    []
  }
  
  var numberOfSectinos: Int {
    2
  }

  var updatedCurrentDay: ((Int) -> Void)?
  
  public init() {
    configure()
  }
  
  private var selectedSection = 0
  
  private var currentDay = 0
  
  var currentDayIndex: Int {
    self.currentDay
  }
  
  var selectedDayIndex: Int {
    self.selectedSection
  }
  
  var sections: [BibleChallengeDayItem] = []
  
  var items: [[BibleChallengeItem]] = []
  
  func configure() {
    self.items = [
      [BibleChallengeItem(isOldTestament: true, challenges: "챌fwefwefwe1", completed: true, hasCompletedAll: true),
       BibleChallengeItem(isOldTestament: false, challenges: "챌wefwefwef2", completed: true, hasCompletedAll: true),
       BibleChallengeItem(isOldTestament: true, challenges: "챌wefwef wef wefefwewefw 3", completed: true, hasCompletedAll: true)],
      [
       BibleChallengeItem(isOldTestament: true, challenges: "3", completed: false, hasCompletedAll: false)],
      [BibleChallengeItem(isOldTestament: true, challenges: "챌1", completed: false, hasCompletedAll: false),
       BibleChallengeItem(isOldTestament: true, challenges: "챌1", completed: false, hasCompletedAll: false),
       BibleChallengeItem(isOldTestament: true, challenges: "챌1", completed: false, hasCompletedAll: false),
       BibleChallengeItem(isOldTestament: false, challenges: "챌2", completed: false, hasCompletedAll: false),
       BibleChallengeItem(isOldTestament: true, challenges: "챌3", completed: false, hasCompletedAll: false)],
      [BibleChallengeItem(isOldTestament: true, challenges: "챌1", completed: false, hasCompletedAll: false),
       BibleChallengeItem(isOldTestament: false, challenges: "챌2", completed: false, hasCompletedAll: false),
       BibleChallengeItem(isOldTestament: true, challenges: "챌3", completed: false, hasCompletedAll: false)],
      [BibleChallengeItem(isOldTestament: true, challenges: "챌1", completed: false, hasCompletedAll: false),
       BibleChallengeItem(isOldTestament: false, challenges: "챌2", completed: false, hasCompletedAll: false),
       BibleChallengeItem(isOldTestament: true, challenges: "챌3", completed: false, hasCompletedAll: false)],
      [BibleChallengeItem(isOldTestament: true, challenges: "챌1", completed: false, hasCompletedAll: false),
       BibleChallengeItem(isOldTestament: false, challenges: "챌2", completed: false, hasCompletedAll: false),
       BibleChallengeItem(isOldTestament: true, challenges: "챌3", completed: false, hasCompletedAll: false)],
      [BibleChallengeItem(isOldTestament: true, challenges: "챌1", completed: false, hasCompletedAll: false),
       BibleChallengeItem(isOldTestament: false, challenges: "챌2", completed: false, hasCompletedAll: false),
       BibleChallengeItem(isOldTestament: true, challenges: "챌3", completed: false, hasCompletedAll: false)],
      [BibleChallengeItem(isOldTestament: true, challenges: "챌1", completed: false, hasCompletedAll: false),
       BibleChallengeItem(isOldTestament: false, challenges: "챌2", completed: false, hasCompletedAll: false),
       BibleChallengeItem(isOldTestament: true, challenges: "챌3", completed: false, hasCompletedAll: false)],
      [BibleChallengeItem(isOldTestament: true, challenges: "챌1", completed: false, hasCompletedAll: false),
       BibleChallengeItem(isOldTestament: false, challenges: "챌2", completed: false, hasCompletedAll: false),
       BibleChallengeItem(isOldTestament: true, challenges: "챌3", completed: false, hasCompletedAll: false)],
      [BibleChallengeItem(isOldTestament: true, challenges: "챌1", completed: false, hasCompletedAll: false),
       BibleChallengeItem(isOldTestament: false, challenges: "챌2", completed: false, hasCompletedAll: false),
       BibleChallengeItem(isOldTestament: true, challenges: "챌3", completed: false, hasCompletedAll: false)]
    ]
    
    self.sections = [
      BibleChallengeDayItem(state: .completed, day: "1"),
      BibleChallengeDayItem(state: .current, day: "2", isSelected: true),
      BibleChallengeDayItem(state: .pending, day: "3"),
      BibleChallengeDayItem(state: .pending, day: "4"),
      BibleChallengeDayItem(state: .pending, day: "5"),
      BibleChallengeDayItem(state: .pending, day: "6"),
      BibleChallengeDayItem(state: .pending, day: "7"),
      BibleChallengeDayItem(state: .pending, day: "8"),
      BibleChallengeDayItem(state: .pending, day: "9"),
      BibleChallengeDayItem(state: .pending, day: "10")
    ]
    
    selectedSection = sections.firstIndex(where: {$0.state == .current}) ?? 0
    currentDay = selectedSection
    updatedCurrentDay?(currentDay)
  }
  
  func numberOfItems(_ section: Int) -> Int {
    if section == 0 {
      return sections.count
    }
    if sections.count > 0 {
      return items[selectedSection].count
    }
    return 0
  }
  
  func section(_ indexPath: IndexPath) -> BibleChallengeDayItem {
    sections[indexPath.item]
  }
  
  func item(_ indexPath: IndexPath) -> BibleChallengeItem {
    items[selectedSection][indexPath.item]
  }
  
  func isAllItemsCompleted() -> Bool {
    let specificItems = items[currentDay]
    return specificItems.filter { $0.completed }.count == specificItems.count
  }
  
  func update(challenge indexPath: IndexPath, completed: Bool) {
    guard indexPath.section == 1 else { return }
    if currentDay != selectedSection { return }
    if currentDay == sections.count { return }

    items[currentDay][indexPath.item].completed = completed
    if self.isAllItemsCompleted() {
      for i in items[currentDay].indices {
        items[currentDay][i].hasCompletedAll = true
      }
    }
  }
  
  func canMoveNextDay() -> Bool {
    if currentDay < sections.count {
      currentDay += 1
      updatedCurrentDay?(currentDay)
      sections[currentDay-1].state = .completed
      /// 맨 마지막의 경우.
      
      if currentDay == sections.count {
        return false
      }
      selectedSection = currentDay
      sections[currentDay-1].isSelected = false
      sections[currentDay].isSelected = true
      sections[currentDay].state = .current
    }
    return currentDay < sections.count
  }
  
  func hasAlreadyShown(_ indexPath: IndexPath) -> Bool {
    indexPath.item == selectedSection
  }
  
  /// Depreciated
  func updateSelectedDay(_ indexPath: IndexPath) {
    sections[selectedSection].isSelected = false
    selectedSection = indexPath.item
    sections[selectedSection].isSelected = true
    
  }
}

final class DailyChallengeViewController: UIViewController {
  // 아 이거 델리게이트 분리해서 이부분 이상해짐..
  var dataSource = DailyChallengeDataSourceProvider()
  
  private lazy var challengeView = BibleChallengeView(
    dataSourceProvider: dataSource, challengeDelegate: self, with: {_, _, _ in  })
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .palette(.appearance)
    view.addSubview(challengeView)
    NSLayoutConstraint.activate([
      challengeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      challengeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      challengeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      challengeView.heightAnchor.constraint(equalToConstant: 300)
    ])
    challengeView.setProgressBar(from: view)
    challengeView.reloadData()
  }
}

extension DailyChallengeViewController: BibleChallengeDelegate {
  func didTapBibleChallenge(_ index: Int) {
    
  }
  
  func updateSelectedDay(_ indexPath: IndexPath) {
    
  }
  
  func prepareToMoveNextDay() {
    
  }
  
  func update(specificDailyChallenge indexPath: IndexPath, readCompleted completed: Bool) {
    dataSource.update(challenge: indexPath, completed: completed)
  }
}
