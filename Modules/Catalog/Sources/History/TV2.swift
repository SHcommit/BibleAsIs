//
//  TV2.swift
//  JourneyOfFaithCatalogApp
//
//  Created by 양승현 on 1/29/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import DomainEntity
import DesignSystem
import DesignSystemItems
import DesignSystemInterface

func numberOfWeeks(in year: Int, month: Int) -> Int {
  let calendar = Calendar.current
  var components = DateComponents()
  components.year = year
  components.month = month
  components.day = 1
  
  guard let firstDayOfMonth = calendar.date(from: components),
        let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
    return 0
  }
  
  let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
  let daysInMonth = range.count
  
  let totalWeeks = (firstWeekday - 1 + daysInMonth + 6) / 7
  
  return totalWeeks
}

final class BibleGardenViewModel: BibleReadingGardenViewDataSource {
  var numberOfItems: Int { 12 }
  
  let items: [BibleGardenItem] = Month.allCases.map {
    let today = Date()
    let calendar = Calendar.current
    
    let weekdayIndex = calendar.component(.weekday, from: today) - 1
    let todayWeekday = Weekday.from(index: weekdayIndex) ?? .monday
    
    let currentMonthIndex = Calendar.current.component(.month, from: Date())
    let currentMonth = Month(rawValue: currentMonthIndex) ?? .january
    
    /// 실제로 이렇게 파악
    let isSixWeeks = numberOfWeeks(in: 2025, month: $0.rawValue) == 6
    if $0 == .january {
      let gardens: [[BibleGardenLevel]] = [
        [.extreme, .high, .low, .low, .veryHigh, .none, .medium],
        [.extreme, .high, .none, .low, .veryHigh, .none, .medium],
        [.high, .low, .veryHigh, .none, .none, .none, .none],
        [.none, .none, .none, .none, .none, .none, .none],
        [.none, .none, .none, .none, .none, .none, .none]
      ]
      return .init(month: $0, weekday: todayWeekday, isThisMonth: currentMonth == $0,
                   isSixWeeks: isSixWeeks, gardens: gardens)
    }
    return .init(month: $0, weekday: todayWeekday, isThisMonth: currentMonth == $0,
                 isSixWeeks: isSixWeeks, gardens: [])
  }
         
  func item(_ indexPath: IndexPath) -> BibleGardenItem {
    items[indexPath.item]
  }
}

class TV2: UIViewController {
  let bibleGardenView = UICollectionView.makeBibleGardenView(frame: .zero)
  let vm = BibleGardenViewModel()
  var bibleGardenViewAdapter: BibleGardenViewAdapter!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    overrideUserInterfaceStyle = .light
    view.backgroundColor = .palette(.appearance)
    [bibleGardenView].forEach(view.addSubview(_:))
    NSLayoutConstraint.activate([
      bibleGardenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      bibleGardenView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      bibleGardenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      bibleGardenView.heightAnchor.constraint(equalToConstant: UICollectionView.bibleGardenViewHeight)
    ])
    bibleGardenViewAdapter = BibleGardenViewAdapter(
      dataSource: vm,
      collectionView: bibleGardenView)
    
    bibleGardenView.reloadData()
  }
}
