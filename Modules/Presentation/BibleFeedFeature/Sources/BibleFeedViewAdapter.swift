//
//  BibleFeedViewAdapter.swift
//  DesignSystem
//
//  Created by 양승현 on 3/18/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import DomainEntity
import DesignSystem
import DesignSystemItems
import DesignSystemInterface

public protocol BibleFeedAdapterBibleNotesDataSource {
  var isNotesEmpty: Bool { get }
  func fetchBibleNoteVerse(indexPath: IndexPath) -> BibleVerse?
  func bibleNotesHeaderItem() -> String?
}

public protocol BibleFeedAdapterBibleHeartsDataSource {
  var isHeartEmpty: Bool { get }
  func fetchBibleHeartVerse(indexPath: IndexPath) -> BibleVerse?
  func bibleHeartHeaderItem() -> String?
}

public protocol BibleFeedAdapterDailyReadingChecklistDataSource {
  func dailyReadingChecklistCardItem() -> DailyBibleReadingChecklistCardItem
  func dailyReadingChecklistDescriptionItem() -> BibleDailyReadingPlanDescriptionItem
  func dailyReadingChecklistHeaderItem() -> String?
}

public protocol BibleFeedAdapterMccCheyneDataSource {
  func mccCheyneHeaderItem() -> String
}

public protocol BibleFeedAdapterRecentBookclipDataSource {
  var recentReadBibleBookClipItem: RecentReadBibleBookclipItem { get }
  func recentBookclipHeaderItem() -> String
}

public protocol BibleFeedAdapterGardenDataSource {
  typealias Year = Int
  func configureGardenCell() -> BibleReadingGardenViewDataSource?
  func gardenHeaderItem() -> Year
}

public protocol BibleFeedAdapterDailyRandomVerseDataSource {
  func dailyRandomVerseHeaderItem() -> String
  func dailyRandomVerseItems() -> [BibleRandomVerseItem]
}

public protocol BibleFeedAdapterDelegate: AnyObject {
  func configChallengeView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell?
  
  func dailyRandomCellContentSizeDidChange(_ cell: UITableViewCell)
  
  func showBibleGardenYearSelectionPage()
  
  /// lazy section loading
  func showBibleReadingChallengeForNewSection()
  
  func showBibleHighlightsForNewSection()
  
  func showBibleNotesForNewSection()
  
  func showBibleReadingPageForRecentReadVerses()
  
  func showBibleReadingChecklistPage()
  
  func showBibleHeartHomePage()
  
  func showBibleNoteHomePage()
  
  func scrollViewDidScroll(withOffsetY: CGFloat)
  
  // MARK: - TapEvent
  func didTapNoteCell(with indexPath: IndexPath)
  
  func didTapHeartCell(with indexPath: IndexPath)
}

public typealias _BibleFeedAdapterDataSource = (
  BibleFeedAdapterGardenDataSource &
  BibleFeedAdapterDailyRandomVerseDataSource &
  BibleFeedAdapterRecentBookclipDataSource &
  BibleFeedAdapterDailyReadingChecklistDataSource &
  BibleFeedAdapterBibleHeartsDataSource &
  BibleFeedAdapterBibleNotesDataSource
)

public protocol BibleFeedAdapterDataSource: AnyObject, _BibleFeedAdapterDataSource {
  /// 내부적으로 initiallyFetched개수에 따라서 numOfSectinos를 증가시킴.
  /// hasInitiallyFetched를 따로 추가 안해도 됨.
  var numberOfFeedSections: Int { get }
  func numberOfFeedItems(of section: BibleFeedSection) -> Int

  /// 특정한 lazy fetching section가 로딩중인지?
  var isLoadingForNewSection: Bool { get }
  /// 초기에 보여져야 하는 섹션들을 받아오는게 끝났는지?
  var isOnceInitialLoadingDone: Bool { get }
  
  /// 데이터는 섹션 순차적으로 받아오자. lazy fetching !
  var isBibleReadingGardenSectionOnceLoaded: Bool { get }
  var isBibleDailyRandomVerseSectionOnceLoaded: Bool { get }
  var isRecentlyReadVerseSectionOnceLoaded: Bool { get }
  var isMccCheyneChallengeSectionOnceLoaded: Bool { get }
  var isBibleReadingChallengeSectionOnceLoaded: Bool { get }
  var isBibleHeartsSectionOnceLoaded: Bool { get }
  var isBibleNotesSectionOnceLoaded: Bool { get }
}

public final class BibleFeedViewAdapter: NSObject {
  // MARK: - Properties
  private weak var dataSource: BibleFeedAdapterDataSource?
  
  private weak var delegate: BibleFeedAdapterDelegate?
  
  private var isBibleReadingGardenInitialScrollingDone = false
  
  /// 초기에 노트를 받아올 때 노트가 없는 경우 애니메이션과 함께 보여져야함
  private var notesAreEmptyHasOnceAppeared = false
  
  /// 초기에 하트를 받아올 때 하트가 없는 경우 애니메이션과 함께 보여져야함
  private var heartsAreEmptyHasOnceAppeared = false
  
  /// 초기에 한번 데이터 받아왔을 때 에니메이션 보여주자.
  /// 그 이후로는 애니메이션 보여주지 않기 위해!
  private var hasOnceDescriptionAppeared = false
  
  /// 참 희안하게.. bookClip 이거 쉐도우 내부에서 처리하려고했고. 동적뷰가 아니라 그냥 높이 지정해도 쉐도우 부여가 안됨
  /// 근데 터치나 꾹? 누르면 그제서야 쉐도우보임. 피드 reusableview reload시점이 좀 빨라서그런가 ...
  ///
  /// layoutSubviews
  private var hasOnceRecentBookclipAppeared = false
  
  // MARK: - Lifecycle
  public init(dataSource: BibleFeedAdapterDataSource, delegate: BibleFeedAdapterDelegate, tableView: UITableView) {
    self.dataSource = dataSource
    self.delegate = delegate
    super.init()
    tableView.dataSource = self
    tableView.delegate = self
  }
}

// MARK: - UITableViewDataSource
extension BibleFeedViewAdapter: UITableViewDataSource {
  /// 시스템 로직상 이게 몇번 호출될 수 있음 근데 실제로 reloadData는 내가 원하는 시점에만 호출된다는거 체크함
  ///
  /// Lazy loading에서 특정 섹션만 새로 insert section할 때도 마찬가지로 numberOfSectinos는 두번씩 호출되는데 cellForRowAt는 한번 호출되는거
  /// 체크함.
  /// 정상 !
  public func numberOfSections(in tableView: UITableView) -> Int {
    guard let dataSource else { return 0 }
    return dataSource.numberOfFeedSections
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let dataSource else { return 0 }
    guard let section = BibleFeedSection(section: section) else { return 0 }
    return dataSource.numberOfFeedItems(of: section)
  }
  
  // MARK: - Cell
  public func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    guard let dataSource else { return .init(frame: .zero) }
    guard let section = BibleFeedSection(indexPath: indexPath) else { return .init(frame: .zero) }
    var _cell: UITableViewCell?
    switch section {
    case .bibleReadingGarden:
      let cell = tableView.dequeueReusableCell(for: indexPath, type: BibleReadingGardenCell.self)
      cell?.configure(with: dataSource.configureGardenCell())
      _cell = cell
    case .bibleDailyRandomVerse:
      let cell = tableView.dequeueReusableCell(for: indexPath, type: BibleDailyRandomVerseCell.self)
      let item = dataSource.dailyRandomVerseItems()
      cell?.configure(with: item)
      cell?.delegate = self
      _cell = cell
    case .recentlyReadVerse:
      let cell = tableView.dequeueReusableCell(for: indexPath, type: RecentReadBibleBookClipCell.self)
      cell?.configure(with: dataSource.recentReadBibleBookClipItem)
      cell?.delegate = self
      _cell = cell
    case .mccCheyneChallenge:
      /// 이 기능은 외부의 모듈을 참조함
      _cell = delegate?.configChallengeView(tableView, cellForRowAt: indexPath)
      
    case .bibleReadingChallenge:
      let isDescriptionRow = indexPath.row == 0
      let isReadingChallengeCardRow = indexPath.row == 1
      if isDescriptionRow {
        let cell = tableView.dequeueReusableCell(for: indexPath, type: BibleReadingChecklistDescriptionCell.self)
        cell?.configure(with: dataSource.dailyReadingChecklistDescriptionItem())
        _cell = cell
      } else if isReadingChallengeCardRow {
        let cell = tableView.dequeueReusableCell(for: indexPath, type: BibleReadingChecklistCell.self)
        cell?.configure(with: dataSource.dailyReadingChecklistCardItem())
        cell?.delegate = self
        _cell = cell
      }
    case .bibleHearts:
      if dataSource.isHeartEmpty {
        let cell = tableView.dequeueReusableCell(for: indexPath, type: HeartsAreEmptyTableViewCell.self)
        _cell = cell
        break
      }
      let item = dataSource.fetchBibleHeartVerse(indexPath: indexPath)
      if item?.book.isOldTestament == true {
        let cell = tableView.dequeueReusableCell(for: indexPath, type: BibleFeedOldTestamentHeartCell.self)
        cell?.configure(with: item)
        _cell = cell
      } else {
        let cell = tableView.dequeueReusableCell(for: indexPath, type: BibleFeedNewTestamentHeartCell.self)
        cell?.configure(with: item)
        _cell = cell
      }
    case .bibleNotes:
      if dataSource.isNotesEmpty {
        let cell = tableView.dequeueReusableCell(for: indexPath, type: NotesAreEmptyTableViewCell.self)
        _cell = cell
        break
      }
      let item = dataSource.fetchBibleNoteVerse(indexPath: indexPath)
      let cell = tableView.dequeueReusableCell(for: indexPath, type: BibleNoteCell.self)
      cell?.configure(with: item)
      _cell = cell
    }
    
    return _cell ?? .init(frame: .zero)
  }
  
  // MARK: - Header
  public func tableView(
    _ tableView: UITableView,
    viewForHeaderInSection section: Int
  ) -> UIView? {
    guard let section = BibleFeedSection(section: section) else { return .init(frame: .zero) }
    guard let dataSource else { assertionFailure("데이터 소스 확인 못함 확인바람"); return nil }
    switch section {
    case .bibleReadingGarden:
      let header = tableView.dequeueReusableHeaderFooterView(
        withIdentifier: BibleReadingGardenHeader.identifier
      ) as? BibleReadingGardenHeader
      header?.configure(with: dataSource.gardenHeaderItem())
      header?.tagTap = { [weak self] in
        self?.delegate?.showBibleGardenYearSelectionPage()
      }
      return header
    case .bibleDailyRandomVerse:
      let header = tableView.dequeueReusableHeaderFooterView(
        withIdentifier: BibleFeedTitleHeader.identifier
      ) as? BibleFeedTitleHeader
      header?.configure(with: dataSource.dailyRandomVerseHeaderItem())
      return header
    case .recentlyReadVerse:
      let header = tableView.dequeueReusableHeaderFooterView(
        withIdentifier: BibleFeedTitleHeader.identifier
      ) as? BibleFeedTitleHeader
      header?.configure(with: dataSource.recentBookclipHeaderItem())
      return header
    case .mccCheyneChallenge:
      return nil
    case .bibleReadingChallenge:
      let header = tableView.dequeueReusableHeaderFooterView(
        withIdentifier: BibleFeedTitleHeader.identifier
      ) as? BibleFeedTitleHeader
      header?.configure(with: dataSource.dailyReadingChecklistHeaderItem())
      return header
    case .bibleHearts:
      let header = tableView.dequeueReusableHeaderFooterView(
        withIdentifier: BibleFeedTitleHeader.identifier
      ) as? BibleFeedTitleHeader
      header?.configure(with: dataSource.bibleHeartHeaderItem(), shouldUseDetailChovernIcon: true)
      header?.tap = { [weak self] in self?.delegate?.showBibleHeartHomePage() }
      return header
    case .bibleNotes:
      let header = tableView.dequeueReusableHeaderFooterView(
        withIdentifier: BibleFeedTitleHeader.identifier
      ) as? BibleFeedTitleHeader
      header?.configure(with: dataSource.bibleNotesHeaderItem(), shouldUseDetailChovernIcon: true)
      header?.tap = { [weak self] in self?.delegate?.showBibleNoteHomePage() }
      return header
    }
  }
}

// MARK: - UITableViewDelegate
extension BibleFeedViewAdapter: UITableViewDelegate {  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let ofy = scrollView.contentOffset.y
    let scrollableHeight = scrollView.contentSize.height - scrollView.bounds.height
    let shouldShowNextPage = ofy > scrollableHeight + 7
    guard let dataSource else { return }
    guard dataSource.isOnceInitialLoadingDone else { return }
    delegate?.scrollViewDidScroll(withOffsetY: ofy)
    guard shouldShowNextPage else { return }
    
    if dataSource.isLoadingForNewSection { return }
    
    if !dataSource.isBibleReadingChallengeSectionOnceLoaded {
      delegate?.showBibleReadingChallengeForNewSection()
    } else if !dataSource.isBibleHeartsSectionOnceLoaded {
      delegate?.showBibleHighlightsForNewSection()
    } else if !dataSource.isBibleNotesSectionOnceLoaded {
      delegate?.showBibleNotesForNewSection()
    }
  }
  
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let section = BibleFeedSection(section: indexPath.section) else { return }
    guard let dataSource else { return }
    if section == .bibleHearts {
      if dataSource.isHeartEmpty { return }
      delegate?.didTapHeartCell(with: indexPath)
    } else if section == .bibleNotes {
      if dataSource.isNotesEmpty { return }
      delegate?.didTapNoteCell(with: indexPath)
    }
  }
  
  public func tableView(
    _ tableView: UITableView,
    willDisplay cell: UITableViewCell,
    forRowAt indexPath: IndexPath
  ) {
    // MARK: - for Lazy loading
    guard let section = BibleFeedSection(section: indexPath.section) else { return }
    /// 한번만: )
    if section == .bibleReadingGarden {
      if cell is BibleReadingGardenCell, !isBibleReadingGardenInitialScrollingDone {
        isBibleReadingGardenInitialScrollingDone = true
        (cell as? BibleReadingGardenCell)?.reloadData()
      }
      return
    }
    
    /// 자연스러운 애니메이션 가보즈아
    if section == .recentlyReadVerse, !hasOnceRecentBookclipAppeared {
      hasOnceRecentBookclipAppeared = true
      (cell as? RecentReadBibleBookClipCell)?.showBgViewWithShadow()
      return
    }
    
    if section == .bibleReadingChallenge {
      if hasOnceDescriptionAppeared { return }
      hasOnceDescriptionAppeared = true
      guard let item = dataSource?.dailyReadingChecklistDescriptionItem() else {
        ToastController.shared.showToast(
          message: "시스템 오류로 인해 성경 통독표 대쉬보드를 볼 수 없습니다.\n잠시 후에 다시 시도해주세요",
          type: .error)
        return
      }
      
      /// 애니메이션 로직
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
        (cell as? BibleReadingChecklistDescriptionCell)?.animateInitialAppearance(
          oldTestamentStructureStatus: item.oldTestamentStructureStatus,
          newTestamentStructureStatus: item.newTestamentStructureStatus)
      }
      return
    }
    
    if section == .bibleNotes {
      if dataSource?.isNotesEmpty == true {
        if !notesAreEmptyHasOnceAppeared {
          notesAreEmptyHasOnceAppeared = true
          (cell as? NotesAreEmptyTableViewCell)?.showAnimation(delay: 0.45)
        }
      } else {
        notesAreEmptyHasOnceAppeared = false
      }
      return
    }

    if section == .bibleHearts {
      if dataSource?.isHeartEmpty == true {
        if !heartsAreEmptyHasOnceAppeared {
          heartsAreEmptyHasOnceAppeared = true
          (cell as? HeartsAreEmptyTableViewCell)?.showAnimation(delay: 0.45)
        }
        
      } else {
        heartsAreEmptyHasOnceAppeared = false
      }
      return
    }
 
    // MARK: - for synchronization
    /// 맥체인은 내 활동의 챌린지 탭과 동기화 되야 함!
    if section == .mccCheyneChallenge {
      (cell as? BibleFeedChallengeCell)?.reloadData()
    }
    return
  }
}

// MARK: - BibleDailyRandomVerseCellDelegate
extension BibleFeedViewAdapter: BibleDailyRandomVerseCellDelegate {
  public func cellContentSizeDidChange(_ cell: UITableViewCell) {
    delegate?.dailyRandomCellContentSizeDidChange(cell)
  }
}

// MARK: - RecentReadBibleBookClipCellDelegate
extension BibleFeedViewAdapter: RecentReadBibleBookClipCellDelegate {
  public func didTapRecentReadBibleBookClipCell(_ cell: UITableViewCell) {
    delegate?.showBibleReadingPageForRecentReadVerses()
  }
}

// MARK: - BibleReadingChecklistCellDelegate
extension BibleFeedViewAdapter: BibleReadingChecklistCellDelegate {
  public func didtapReadingChecklistCell(_ cell: UITableViewCell) {
    delegate?.showBibleReadingChecklistPage()
  }
}
