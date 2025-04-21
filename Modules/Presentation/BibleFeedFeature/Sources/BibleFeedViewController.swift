//
//  BibleFeedViewController.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 3/18/25.
//

import UIKit
import Common
import RxSwift
import ReactorKit
import DomainEntity
import DesignSystem
import DesignSystemItems
import BibleFeedInterface

/// 새로 화면을 들어올 때마다 바이블 가든은 현재 년도 꺼로 보여질 수 있도록 반영
class BibleFeedViewController: BaseViewController, View {
  typealias Reactor = BibleFeedReactor
  
  private let customNavigationBarHeight = 48.0
  
  // MARK: - Properties
  var disposeBag: DisposeBag = DisposeBag()
  
  private let feedView = UITableView.makeFeedView().then {
    $0.register(BibleFeedChallengeCell.self)
  }
  
  /// status bar.
  private let notchBackgroundBar = UIView(frame: .zero).then {
    $0.setAutoLayout()
    $0.backgroundColor = .palette(.appearance)
  }
  
  /// 기존에는 스크롤할 때 네비바를 안보여주고, 위로 올릴때 보여주고 했는데 좀 부자연스러워서 자연스럽게 할라고 이렇게 함
  private let customNavigationView = UIView(frame: .zero).then {
    $0.setAutoLayout()
    $0.backgroundColor = .clear
  }
  
  private let appLogoImageView = UIImageView(frame: .zero).then {
    $0.setAutoLayout()
    $0.backgroundColor = .clear
    $0.setImage(image: .asset(.appLogo))
  }
  
  private lazy var rightBarButtonImageView = PaddingImageView(padding: .init(inset: 7), imageViewFactory: {
    $0.backgroundColor = .clear
    $0.setScaleAspectFit()
    $0.setImage(image: .asset(.menu3))
  }).then {
    $0.setAutoLayout()
    $0.isUserInteractionEnabled = true
    let tap = UITapGestureRecognizer(target: self, action: #selector(didTapNavigationBarMenu))
    $0.addGestureRecognizer(tap)
  }
  
  private var feedViewAdapter: BibleFeedViewAdapter!
  
  private let flowDependencies: BibleFeedFlowDependencies
  
//  private var userSelectionYear: Int?
  
  private var hasEntrySetupDone = false
  
  /// 갑자기 위로 살짝 스크롤 했다 빠르게 아래로 내려가는 경우 커스텀 내비바 현 위치 + 최소한의 transform 요청 대응.
  private var isCustomNavigationTransformIdentity = false
  
  private var refreshControl = UIRefreshControl()
  
  // MARK: - Lifecycle
  init(flowDependencies: BibleFeedFlowDependencies) {
    self.flowDependencies = flowDependencies
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) { nil }
  
  override func viewDidLoad() {
    navigationController?.setNavigationBarHidden(true, animated: false)
    super.viewDidLoad()
    
    view.backgroundColor = .palette(.appearance)
    showGradientView()
    configureRefreshControl()
//    navigationItem.title = "앱이름 지어야함"
//    let menuItem = UIBarButtonItem.makeFeedNaviMenuItem(self, action: #selector(didTapNavigationBarMenu))
//    navigationItem.setRightBarButton(menuItem, animated: true)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // 네비바 숨김
//    if navigationController?.isNavigationBarHidden == false {
//      navigationController?.setNavigationBarHidden(true, animated: false)
//    }
    
    if !hasEntrySetupDone {
      hasEntrySetupDone = true
      guard let reactor else {
        assertionFailure("지금 즉시! 뷰 인스턴스 주입할 때 리엑터 데이터 할당했는지 보시오!")
        ToastController.shared.showToast(message: "오류가 발생되어 피드 화면을 실행할 수 없습니다.", type: .success)
        return
      }
      feedViewAdapter = BibleFeedViewAdapter(
        dataSource: reactor, delegate: self,
        tableView: feedView)
      /// Warning once only: UITableView was told to layout its visible cells and other contents without being in the view hierarchy
      /// 뷰 디드 로드시점에 화면 리프래쉬되면 위와 같은 에러 떠 ㅜㅜ
      reactor.action.onNext(.viewDidLoad)
      return
    }
    reactor?.action.onNext(.viewWillAppear)
  }
  
  // MARK: - LayoutUI
  override func layoutUI() {
    super.layoutUI()
    [appLogoImageView, rightBarButtonImageView].forEach(customNavigationView.addSubview(_:))
    
    NSLayoutConstraint.activate([
      appLogoImageView.leadingAnchor.constraint(equalTo: customNavigationView.leadingAnchor, constant: 16),
      appLogoImageView.centerYAnchor.constraint(equalTo: customNavigationView.centerYAnchor),
      appLogoImageView.widthAnchor.constraint(equalToConstant: 48),
      appLogoImageView.heightAnchor.constraint(equalToConstant: 48),
      
      rightBarButtonImageView.trailingAnchor.constraint(equalTo: customNavigationView.trailingAnchor, constant: -9),
      rightBarButtonImageView.centerYAnchor.constraint(equalTo: customNavigationView.centerYAnchor),
      rightBarButtonImageView.widthAnchor.constraint(equalToConstant: 34),
      rightBarButtonImageView.heightAnchor.constraint(equalToConstant: 34)
    ])
    
    [feedView, customNavigationView, notchBackgroundBar].forEach(view.addSubview(_:))
    
    NSLayoutConstraint.activate([
      customNavigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      customNavigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      customNavigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      customNavigationView.heightAnchor.constraint(equalToConstant: customNavigationBarHeight),
      
      notchBackgroundBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      notchBackgroundBar.topAnchor.constraint(equalTo: view.topAnchor),
      notchBackgroundBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      notchBackgroundBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      
      feedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      feedView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      feedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      feedView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
  }
  
  // MARK: - Bind
  func bind(reactor: BibleFeedReactor) {
    reactor.state
      .map { $0.isOnceInitialLoadingDoneCompletion }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] hasDone in
        guard let self, hasDone else { return }
        feedView.reloadData()
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.dailyReadingChecklistCardItemFetchedCompletion }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] hasFetched in
        guard let self, hasFetched else { return }
        
        let section = BibleFeedSection.bibleReadingChallenge
        let sectionIndexSet = IndexSet(integer: section.toSection)
        /// 섹션 추가
        if reactor.currentState.newSectionInitiallyShow {
          // 퍼폼쓰면 어떤 상황에선 부자연스러움
//          UIView.performWithoutAnimation {
//            self.feedView.performBatchUpdates {
//              self.feedView.tableFooterView = nil
//              self.feedView.insertSections(sectionIndexSet, with: .none)
//            }
//          }
          
          if feedView.tableFooterView == nil { return }
          
          feedView.performBatchUpdates {
            self.feedView.tableFooterView = nil
            self.feedView.insertSections(sectionIndexSet, with: .none)
          }
          
        } else {
          /// 섹션 리로드
          feedView.reloadSections(sectionIndexSet, with: .none)
        }
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.bibleHeartVersesFetchedCompletion }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] hasFetched in
        guard let self, hasFetched else { return }
        let section = BibleFeedSection.bibleHearts
        let sectionIndexSet = IndexSet(integer: section.toSection)
        /// 섹션 추가
        if reactor.currentState.newSectionInitiallyShow {
          self.feedView.performBatchUpdates {
            self.feedView.tableFooterView = nil
            self.feedView.insertSections(sectionIndexSet, with: .fade)
          }
        } else {
          /// 섹션 리로드
          if section.toSection < feedView.numberOfSections {
            self.feedView.reloadSections(sectionIndexSet, with: .none)
          } else {
            self.feedView.performBatchUpdates {
              self.feedView.tableFooterView = nil
              self.feedView.insertSections(sectionIndexSet, with: .fade)
            }
            print("DEBUG: \(Self.self). 이거 무슨상황이지?, 아니 이렇게 될 수 가 없는데?!?!?!?!")
          }
        }
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.bibleNoteVersesFetchedCompletion }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] hasFetched in
        guard let self, hasFetched else { return }
        let section = BibleFeedSection.bibleNotes
        let sectionIndexSet = IndexSet(integer: section.toSection)
        /// 섹션 추가
        if reactor.currentState.newSectionInitiallyShow {
          self.feedView.performBatchUpdates {
            self.feedView.tableFooterView = nil
            self.feedView.insertSections(sectionIndexSet, with: .fade)
          }
        } else {
          if section.toSection < feedView.numberOfSections {
            self.feedView.reloadSections(sectionIndexSet, with: .none)
          } else {
            /// 섹션 리로드
            self.feedView.performBatchUpdates {
              self.feedView.tableFooterView = nil
              self.feedView.insertSections(sectionIndexSet, with: .fade)
            }
            print("DEBUG: \(Self.self). 이거 무슨상황이지?, 아니 이렇게 될 수 가 없는데?!?!?!?!")
          }
        }
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.viewWillAppearRefreshed }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] hasFetched in
        guard let self, hasFetched else { return }
        // 이거 에러 발생됨.
        // _Bug_Detected_In_Client_Of_UITableView_Invalid_Number_Of_Rows_In_Section:]
//        'Invalid update: invalid number of rows in section 5.
        // The number of rows contained in an existing section after the update (3) must be equal to the number of rows contained in that section before the update (1),
        // plus or minus the number of rows inserted or deleted from that section (0 inserted, 0 deleted)
        // and plus or minus the number of rows moved into or out of that section (0 moved in, 0 moved out).
//        UIView.performWithoutAnimation {
//          self.feedView.performBatchUpdates {
//            self.feedView.reloadData()
//          } completion: { _ in
//            self.feedView.setContentOffset(previousOffset, animated: false)
//          }
//        }
//        
//        UIView.performWithoutAnimation {
//          self.feedView.reloadData()
//        }
        self.feedView.reloadData()
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.annualReadingGardenCommitsFetchedCompletion }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] hasFetched in
        guard let self else { return }
        /// 초기에  lazy loading을 위해 한번 받아오기전엔 이 로직 사용x.
        /// 초기에 화면에 바이블 가든이 보여진 후에 사용자가 특정 한 Bible garden 연도를 보고 싶은 경우에만 호출되기 위함임
        if !reactor.isOnceInitialLoadingDone { return }
        
        guard hasFetched else { return }
        
        if refreshControl.isRefreshing {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.34, execute: {
            let bibleGardenSection = BibleFeedSection.bibleReadingGarden.toSection
            self.feedView.reloadSections(IndexSet(integer: bibleGardenSection), with: .automatic)
            self.refreshControl.endRefreshing()
          })
        } else {
          let bibleGardenSection = BibleFeedSection.bibleReadingGarden.toSection
          
          self.feedView.reloadSections(IndexSet(integer: bibleGardenSection), with: .automatic)
        }
        
      }).disposed(by: disposeBag)
  }
}

// MARK: - Helpers
extension BibleFeedViewController {
  func configureRefreshControl() {
    refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    refreshControl.tintColor = .palette(.primaryColor)
    refreshControl.transform = .init(scaleX: 0.7, y: 0.7)
    feedView.refreshControl = refreshControl
  }
}

// MARK: - Actions
extension BibleFeedViewController {
  @objc func handleRefresh() {
    let curYear = Calendar.current.component(.year, from: Date())
    reactor?.action.onNext(
      .annualReadingGardenCommitsFetch(
        year: curYear,
        isUserPickYear: false))
  }
  
  @objc func didTapNavigationBarMenu() {
    flowDependencies.showFeedSettingPage()
  }
}

// MARK: - BibleFeedAdapterDelegate
extension BibleFeedViewController: BibleFeedAdapterDelegate {
  func scrollViewDidScroll(withOffsetY offsetY: CGFloat) {
    if offsetY < 0 {
      let dragForRefresh = offsetY + customNavigationBarHeight < 0
      if !dragForRefresh, !customNavigationView.isHidden {
        customNavigationView.transform = CGAffineTransform(translationX: 0, y: -(offsetY + customNavigationBarHeight))
        view.layoutIfNeeded()
        isCustomNavigationTransformIdentity = false
      } else {
        if !isCustomNavigationTransformIdentity {
          /// 강하게 당긴경우
          if offsetY < -(customNavigationBarHeight + 14) {
            isCustomNavigationTransformIdentity = true
            customNavigationView.isHidden = false
            customNavigationView.transform = .identity
          }
        }
      }
    }
    
    if offsetY >= 0, !customNavigationView.isHidden {
      customNavigationView.isHidden = true
    } else if offsetY < 0, customNavigationView.isHidden {
      customNavigationView.isHidden = false
    }
  }
  
  func showBibleReadingChecklistPage() {
    flowDependencies.showBibleReadingChecklistPage()
  }
  
  func showBibleReadingPageForRecentReadVerses() {
    guard let recentReadBibleBookclipItem = reactor?.currentState.recentReadBibleBookclipItem else {
      ToastController.shared.showToast(
        message: "시스템 오류로 인해 최근 본 성경 구절 화면을 들어갈 수 없습니다.\n잠시 후에 다시 시도해주세요.",
        type: .error)
      return
    }
    flowDependencies.showBibleReadingPageForRecentReadVerses(with: recentReadBibleBookclipItem)
  }
  
  func showBibleHeartHomePage() {
    flowDependencies.showBibleHeartHistoryPage()
  }
  
  func showBibleNoteHomePage() {
    flowDependencies.showBibleNoteHomePage(entryWithNote: nil, andEntryVerseforNote: nil)
  }
  
  /// 이거 원래 랜덤 벌스 7개씩! 보여지는거 동적 높이로 결정해서 이 섹션의 높이가 동적으로 변하고 아래 섹션 높이들 contentSize가 동적으로 변하게 하려고 했었음.
  /// 이렇게 섹션이 동적으로 변해야할 상황은 (테이블뷰 or 컬랙션뷰).performBatchUpdates 안에서 써야만 섹션들 높이가 동적으로 조절됨.
  /// 그렇지 않으면 A 섹션 높이는 변하는데 그 아래 B섹션 높이는 (contentSize의 위치가 변하지 않아) 그대로임. offset이 그대로란 말이다 이말인것이다!
  /// 그런데 지금 일단 보류. 사용안함.
  ///
  /// 그냥 애니메이션만 보여주도록
  func dailyRandomCellContentSizeDidChange(_ cell: UITableViewCell) {
    (cell as? BibleDailyRandomVerseCell)?.showAnimation(completion: {
//      self.feedView.performBatchUpdates {
//        cell.contentView.layoutIfNeeded()
//      }
    })
  }
  
  func configChallengeView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell? {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: BibleFeedChallengeCell.identifier,
      for: indexPath
    ) as? BibleFeedChallengeCell
    cell?.configure(with: flowDependencies.makeMccCheynechallengeViewController)
    return cell
  }
  
  func showBibleReadingChallengeForNewSection() {
    feedView.tableFooterView = LoadingTableViewFooterView(
      frame: .init(origin: .zero,
                   size: .init(width: 0, height: LoadingTableViewFooterView.Height)))
    reactor?.action.onNext(.dailyReadingChecklistCardFetch(forNewSection: true))
  }
  
  func showBibleHighlightsForNewSection() {
    feedView.tableFooterView = LoadingTableViewFooterView(
      frame: .init(origin: .zero,
                   size: .init(width: 0, height: LoadingTableViewFooterView.Height)))
    reactor?.action.onNext(.bibleHeartVersesFetch(forNewSection: true))
  }
  
  func showBibleNotesForNewSection() {
    feedView.tableFooterView = LoadingTableViewFooterView(
      frame: .init(origin: .zero,
                   size: .init(width: 0, height: LoadingTableViewFooterView.Height)))
    reactor?.action.onNext(.bibleNoteVersesFetch(forNewSection: true))
  }
  
  func showBibleGardenYearSelectionPage() {
    guard let selectionYear = reactor?.currentState.selectionYearForBibleGarden else {
      ToastController.shared.showToast(
        message: "시스템 오류로 인해 연도를 선택할 수 없습니다/n잠시 후에 다시 시도해주세요",
        position: .bottom,
        type: .error)
      return
    }
    
    flowDependencies.showBibleGardenYearSelectionPage(withUserSelectionYear: selectionYear) { [weak self] userSelectionYear in
      guard let self else { return }
      print("사용자가 이거를 골라써요!", userSelectionYear)
      let isUserSelectYearEqualToCurrentShowingYear = userSelectionYear == selectionYear
      if isUserSelectYearEqualToCurrentShowingYear { return }
      
      reactor?.action.onNext(.annualReadingGardenCommitsFetch(year: userSelectionYear, isUserPickYear: true))
    }
  }
  
  func didTapNoteCell(with indexPath: IndexPath) {
    guard
      let noteRef = reactor?.currentState.bibleNoteReferences[indexPath.row],
      let noteVerseRef = reactor?.currentState.bibleNoteVerses[indexPath.row]
    else {
      ToastController.shared.showToast(
        message: "시스템 오류로 인해 노트 화면으로 이동할 수 없습니다.\n잠시 후 다시 시도해주세요.",
        type: .error)
      return
    }
    
    flowDependencies.showBibleNoteHomePage(entryWithNote: noteRef, andEntryVerseforNote: noteVerseRef)
  }
  
  func didTapHeartCell(with indexPath: IndexPath) {
    flowDependencies.showBibleHeartHistoryPage()
  }
}
