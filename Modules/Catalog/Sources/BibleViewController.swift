//
//  BibleViewController.swift
//  JourneyOfFaithCatalogApp
//
//  Created by 양승현 on 2/5/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import DomainEntity
import DesignSystem
import DesignSystemItems
import DesignSystemInterface

final class BibleViewReactor: BibleReadingViewDataSource {
  func fetchPageInfo() -> BibleReadingPageControlItem {
    .init(currentChapter: 1, numberOfChapters: 50, shouldHidePrevButton: false, shouldHideNextButton: false, isExecutingAudioMode: false)
  }
  
  var numberOfSections: Int = 1
  
  var numberOfItems: Int = 50
  
  var isOldTestament: Bool {
    true
  }
  
  var items: [BibleVerseItem] = []
  
  var numberOfChapters: Int {
    bible.numberOfChapters
  }
  
  var currentChapter: Int = 1
  
  var bible: BibleBook = .genesis
  
  init() {
    fetchVerses()
  }
  
  func item(_ indexPath: IndexPath) -> BibleVerseItem {
    items[indexPath.item]
  }
  
  func fetchVerses() {
    items = (0..<numberOfChapters).map {
      var text = "그 때에 왕의 서기관들이 왕의 명령을 따라 제삼 달 곧 십일일에 왕의 도장을 찍고, 각 지방 백성들의 언어와 각 민족들의 글로 된 법령을 제시하여, 왕의 명령을 전하게 되었다. 모든 도시는 각 민족과 각 방언에 따라 작성되었으며, 그것은 왕의 명령에 따라 모든 사람들이 각자의 요구를 만족시킬 수 있도록 하기 위해서였다."
      if $0 == 0 {
        return BibleVerseItem(
          reference: .init(book: .acts, chapter: 1, verse: 21),
          verseContent: text + text, isOnHeart: true, highlights: [
            .init(id: .init(), range: .init(location: 2, length: 7), colorIndex: .blue)
          ], note: .init(noteId: .init(), range: .init(location: 12, length: 14), text: "뀨?"))
      } else if $0 == 1 {
        text = "밤 네 시쯤에 예수께서 물 위를 걸어서 제자들에게 오시니 제자들이 그를 보고 무서워하며 말하되 ‘유령이다!’ 하고 무서워하여 떨었으나 예수께서 즉시 이르시되 ‘안심하라, 내니 두려워하지 말라!’ 하시니라. 베드로가 대답하여 이르되 ‘주여, 만일 주께서시거든 나를 명하여 물 위로 오게 하소서’ 하니, 오라 하시니 베드로가 배에서 내려 물 위로 걸어 예수께 나아가되"
      } else if $0 == 2 {
        text = "예수께서 눈을 들어 큰 무리가 자기에게 오는 것을 보시고 빌립에게 이르시되 ‘우리가 어디서 떡을 사서 이 사람들에게 먹이겠느냐?’ 하시니 이는 자기를 시험하려고 하심이라. 빌립이 대답하되 ‘각 사람에게 조금씩 떡을 주기에도 이십 이드라리온의 떡이 부족하겠나이다’ 하니라. 그 때에 제자 중 하나, 곧 시몬 베드로의 형제 안드레가 예수께 이르되 ‘여기 한 아이가 있어 보리떡 다섯 개와 물고기 두 마리가 있으나 이게 무슨 소용이 있겠습니까?’ 예수께서 이르시되 ‘사람들이 앉게 하라’ 하시니 그 곳에는 풀밭이 많더라. 이에 사람들이 앉으니 수가 오천 명 가량 되었더라. 예수께서 떡을 취하여 앉은 자들에게 나누어 주시고 물고기도 그렇게 하여 그들이 원하는 대로 주시니라"
      } else if $0 == 3 {
        text = "라라 라라라"
      } else if $0 == 5 {
        text = "라라라"
      }
      return BibleVerseItem(
        reference: .init(book: .genesis, chapter: 1, verse: 1),
        verseContent: text, isOnHeart: true, highlights: [], note: nil)
    }
  }
  
  func fetchBookChapterText() -> String {
    "\(bible.name) \(currentChapter)장"
  }
  
  func fetchPageInfo() -> (currentChapter: Int, numberOfChapters: Int) {
    (currentChapter, numberOfChapters)
  }
}

final class BibleViewController: UIViewController {
  // MARK: - Properties
  private lazy var bibleView = BibleReadingView(frame: .zero)
  
  private var reactor: BibleViewReactor = .init()
  
  private var bibleViewAdapter: BibleReadingViewAdapter!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bibleViewAdapter = BibleReadingViewAdapter(
      dataSource: reactor,
      delegate: self,
      collectionView: bibleView)
    
    view.backgroundColor = .palette(.appearance)
    bibleView.layout(from: view)
    bibleView.reloadData()
  }
}

// MARK: - BibleReadingViewDelegate
extension BibleViewController: BibleReadingViewDelegate {
  func showPrevChapter(bySleepTimer: Bool) {
    
  }
  
  func showNextChapter(bySleepTimer: Bool) {
    
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) { }
  
  func addNote(_ cell: UICollectionViewCell, range: NSRange) { }
  
  func deleteNote(_ cell: UICollectionViewCell) { }
  
  func willDisplayTitleHeaderView() { }
  
  func disappearTitleHeaderView() { }
  
  func deleteNote(_ cell: UICollectionViewCell, noteId: Int) { }
  
  func deleteHighlight(_ cell: UICollectionViewCell, id: Int) { }
  
  func updateIndicatorWidth(_ width: CGFloat) {
    bibleView.updateScrollIndicator(width)
  }
  
  func readCompletionThisChapter() {
    print("읽기 완료! 다음 화면 가기 하지 말기!!!!!")
  }
  
  func showPrevChapter() {
    print("이전화면 가보긔")
  }
  
  func showNextChapter() {
    print("다음화면 가보긔")
  }
  
  func tapHeart(_ cell: UICollectionViewCell) {
    if bibleView.indexPath(for: cell) == nil { return }
    // 특정 하트 isOn false하도록 데이터 수정
    // 근데 아직 고민중.. 안할까 생각임
  }
  
  func tapNote(_ cell: UICollectionViewCell) {
    if bibleView.indexPath(for: cell) == nil { return }
    // 특정 노트 상세 화면 들어가기
  }
  
  func showColorPickerAlert(
    _ cell: UICollectionViewCell,
    range: NSRange,
    withAlert alert: UIAlertController
  ) {
    if bibleView.indexPath(for: cell) == nil { return }
    present(alert, animated: true)
  }
  
  func toggleHeart(
    _ cell: UICollectionViewCell,
    isOnHeart: Bool
  ) {
    if bibleView.indexPath(for: cell) == nil { return }
    // 특정 하트 isOn false하도록 데이터 수정
  }
  
  func addColor(
    _ cell: UICollectionViewCell,
    range: NSRange,
    colorIndex: HighlightColorIndex,
    completion: (BibleVerseHighlightItem) -> Void
  ) {
    if bibleView.indexPath(for: cell) == nil { return }
    // 인스턴스 생성하고 컴플리션으로 데이터 보내서 반영하기 + reduce에도 보내기
    completion(.init(id: .init(), range: range, colorIndex: colorIndex))
  }
  
  func addNote(
    _ cell: UICollectionViewCell,
    range: NSRange,
    completion: (BibleVerseNoteItem) -> Void
  ) {
    if bibleView.indexPath(for: cell) == nil { return }
    // 인스턴스 생성하고 컴플리션으로 데이터 보내서 반영하기 + reduce에도 보내기
    completion(.init(noteId: 1, range: range, text: "hihihihi"))
  }
  
  func deleteNote(_ cell: UICollectionViewCell, uuid: UUID) {
    if bibleView.indexPath(for: cell) == nil { return }
    // reduce에 반영
  }
  
  func deleteHighlight(_ cell: UICollectionViewCell, uuid: UUID) {
    if bibleView.indexPath(for: cell) == nil { return }
    // reduce에 반영
  }
}
