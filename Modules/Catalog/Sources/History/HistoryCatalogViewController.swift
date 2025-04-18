//
//  HistoryCatalogViewController.swift
//  JourneyOfFaithCatalogApp
//
//  Created by 양승현 on 1/24/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import DesignSystem
import DesignSystemItems

final class HistoryCatalogViewController: UIViewController {
  private let searchedVersesHistoryView: BibleVersesTimelineView = .init()
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(searchedVersesHistoryView)
    
    NSLayoutConstraint.activate([
      searchedVersesHistoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      searchedVersesHistoryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      searchedVersesHistoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      searchedVersesHistoryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
    view.backgroundColor = .palette(.appearance)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    injectDataSourceToSearchedVersesHistoryView()
  }
  
  private func injectDataSourceToSearchedVersesHistoryView() {
//    let sections: [BibleTimelineHistoryVerseSectionItem] = [
//      BibleTimelineHistoryVerseSectionItem(monthDay: "1월 25일", year: "2025"),
//      BibleTimelineHistoryVerseSectionItem(monthDay: "1월 24일", year: "2025"),
//      BibleTimelineHistoryVerseSectionItem(monthDay: "1월 23일", year: "2025"),
//      BibleTimelineHistoryVerseSectionItem(monthDay: "1월 22일", year: "2025")
//    ]
//    
//    let bookName = "창세기"
//    let chapterView = "1:20"
//    let verse = "하나님이 이르시되 물들은 생물은 번성하여 움직이는 모든 생물을 그 종류대로, 날개있는 모든 새를 그 종류대로 창조하시니 하나님이 보시기에 좋았더라"
//    let verse2 = "하나님이 이르시되 물들은 생물은 번성하여 움직이는 모든 생물을 그 종류대로, 날개있는 모든 새를 그 종류대로 창조하시니 하나님이 보시기에 좋았더라 하나님이 이르시되 물들은 생물은 번성하여 움직이는 모든 생물을 그 종류대로, 날개있는 모든 새를 그 종류대로 창조하시니 하나님이 보시기에 좋았더라"
//    let verse3 = "하나님이 이르시되 물들은 생물은 번성하여 움직이는 모든 생물을 그 종류대로"
    
    // let items: [[BibleTimelineHistoryVerseItem]] = [
//      [
//        BibleTimelineHistoryVerseItem(
//          heartId: 1, isOldTestament: true,
//          bookName: bookName,
//          chapterVerse: chapterView, verse: verse, isFirst: true, isLast: false),
//        BibleTimelineHistoryVerseItem(
//          heartId: 2, isOldTestament: false,
//          bookName: bookName,
//          chapterVerse: chapterView, verse: verse2, isFirst: false, isLast: false),
//        BibleTimelineHistoryVerseItem(
//          heartId: 3, isOldTestament: true,
//          bookName: bookName,
//          chapterVerse: chapterView, verse: verse, isFirst: false, isLast: true)
//      ], [
//        BibleTimelineHistoryVerseItem(
//          heartId: 4, isOldTestament: true,
//          bookName: bookName,
//          chapterVerse: chapterView, verse: verse3, isFirst: true, isLast: false),
//        BibleTimelineHistoryVerseItem(
//          heartId: 5, isOldTestament: false,
//          bookName: bookName,
//          chapterVerse: chapterView, verse: verse2, isFirst: false, isLast: true)
//      ], [
//        BibleTimelineHistoryVerseItem(
//          heartId: 6, isOldTestament: false,
//          bookName: bookName,
//          chapterVerse: chapterView, verse: verse, isFirst: true, isLast: true)
//      ], [
//        BibleTimelineHistoryVerseItem(
//          heartId: 7, isOldTestament: true,
//          bookName: bookName,
//          chapterVerse: chapterView, verse: verse3, isFirst: true, isLast: false),
//        BibleTimelineHistoryVerseItem(
//          heartId: 8, isOldTestament: false,
//          bookName: bookName,
//          chapterVerse: chapterView, verse: verse, isFirst: false, isLast: false),
//        BibleTimelineHistoryVerseItem(
//          heartId: 9, isOldTestament: true,
//          bookName: bookName,
//          chapterVerse: chapterView, verse: verse2, isFirst: false, isLast: false),
//        BibleTimelineHistoryVerseItem(
//          heartId: 10, isOldTestament: true,
//          bookName: bookName,
//          chapterVerse: chapterView, verse: verse, isFirst: false, isLast: true)
//      ]
//    ]
    
    // searchedVersesHistoryView.configure(sections, items: items)
  }

}
