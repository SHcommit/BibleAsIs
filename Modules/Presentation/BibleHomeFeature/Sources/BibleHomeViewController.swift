//
//  BibleHomeViewController.swift
//  BibleHomeFeature
//
//  Created by 양승현 on 2/10/25.
//

import UIKit
import Common
import RxSwift
import ReactorKit
import DomainEntity
import DesignSystem
import DesignSystemItems
import BibleHomeInterface
import DesignSystemInterface

/// 아흑 폰트 크기 키우니까 화면 작은 폰에서는 짤려보여서 스크롤 넣어야함
public final class BibleHomeViewController: BaseViewController, View {
  // MARK: - Properties
  private lazy var scrollView = UIScrollView()
    .setAutoLayout()
    .then {
      $0.showsVerticalScrollIndicator = false
      $0.showsHorizontalScrollIndicator = false
      $0.contentInset = .zero
      $0.alwaysBounceVertical = true
      $0.alwaysBounceHorizontal = false
      $0.contentInsetAdjustmentBehavior = .never
    }
  
  private(set) lazy var isExpanded = false {
    didSet {
      if isExpanded {
        scrollView.isScrollEnabled = false
        tableView.isScrollEnabled = true
        carouselView.isHidden = true
        titleAndSubtitleView.isHidden = true
        bibleInformation.isHidden = true
        tags.isHidden = false
        carouselView.pauseAutoScroll()
      } else {
        scrollView.isScrollEnabled = true
        tableView.isScrollEnabled = false
        carouselView.isHidden = false
        titleAndSubtitleView.isHidden = false
        bibleInformation.isHidden = false
        tags.isHidden = true
        NSLayoutConstraint.deactivate(defaultConstraints)
        NSLayoutConstraint.deactivate(expandedConstraints)
        
        NSLayoutConstraint.activate(defaultConstraints)
        guard isInitialSetUp else { return }
        UIView.animate(withDuration: 0.24, delay: 0, options: .curveEaseInOut, animations: {
          self.view.layoutIfNeeded()
        }, completion: { _ in
          self.carouselView.restartAll()
        })
      }
    }
  }
  
  private lazy var tags = UIStackView(arrangedSubviews: makeTags()).then {
    $0.axis = .horizontal
    $0.alignment = .leading
    $0.spacing = 7
    $0.distribution = .equalCentering
    $0.setAutoLayout()
    $0.isHidden = true
    $0.backgroundColor = .palette(.appearance)
  }
  
  private var searchController: UISearchController!
  
  private var isInitialSetUp = false
  
  private(set) var carouselView = HorizontalVerseCarouselView(
    cellInsetFromCollectionView: .init(inset: 16),
    lineSpacing: 10,
    shouldStartAutoCarousel: true
  ).setAutoLayout()
  
  private let titleAndSubtitleView = TitleSubtitleView(
    spacing: 16,
    titleLabelFactory: {
      $0.text = "마음에 새길 구절을 찾아보세요"
      $0.font = .appleSDGothicNeo(.bold, size: 25)
      $0.textColor = .palette(.title)
    },
    subtitleLabelFactory: {
      $0.text = "가장 소중한 시간,\n하나님의 말씀으로 마음을 채워보세요"
      $0.font = .appleSDGothicNeo(.regular, size: 14)
      $0.textColor = .palette(.description)
      $0.numberOfLines = 2
      $0.textAlignment = .center
    }).then {
      $0.setAutoLayout()
      $0.alignment = .center
      $0.backgroundColor = .clear
    }
  
  private let bibleInformation = UILabel(frame: .zero).then {
    $0.setAutoLayout()
    $0.text = "- 개역한글판 -"
    $0.textColor = .palette(.description)
    $0.font = .appleSDGothicNeo(.light, size: 10)
  }
  
  private let tableView = UITableView.makeBibleHomeAccordionView(frame: .zero)
    
  private(set) var expandedConstraints: [NSLayoutConstraint] = []
  
  private(set) var defaultConstraints: [NSLayoutConstraint] = []
  
  private(set) var oldTestamentTagsShow: Handler?
  
  private(set) var oldTestamentTagsHide: Handler?
  
  private(set) var newTestamentTagsShow: Handler?
  
  private(set) var newTestamentTagsHide: Handler?
  
  public typealias Reactor = BibleHomeReactor
  
  public var disposeBag: RxSwift.DisposeBag = DisposeBag()
  
  private var adapter: BibleHomeViewAdapter!
  
  private(set) var flowDependencies: BibleHomeFlowDependencies
  
  private var hasAlreadyPreloadSetup = false
  
  // MARK: - Lifecycle
  public init(flowDependencies: BibleHomeFlowDependencies) {
    self.flowDependencies = flowDependencies
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) { nil }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    confiugreSearchController()
    view.backgroundColor = .palette(.appearance)
    definesPresentationContext = false
    
    guard let reactor else { return }
    adapter = BibleHomeViewAdapter(
      dataSource: reactor,
      delegate: self,
      tableView: tableView)
    showGradientView()
  }
  
  public func confiugreSearchController() {
    searchController = UISearchController(searchResultsController: nil)
    searchController.searchBar.searchTextField.font = .appleSDGothicNeo(.light, size: 14)
    searchController.searchBar.placeholder = "검색어 입력, 구절(창 1:7)"
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.automaticallyShowsCancelButton = false
    searchController.searchBar.delegate = self
    searchController.searchBar.searchTextField.isSelected = false
    searchController.modalPresentationStyle = .fullScreen
    navigationItem.titleView = searchController.searchBar
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.titleView = searchController.searchBar
    if navigationController?.isNavigationBarHidden == true {
      navigationItem.titleView = searchController.searchBar
      navigationController?.isNavigationBarHidden = false
    }
    
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      if !isInitialSetUp {
        isInitialSetUp = true
        configCarousel()
        isExpanded = false
        tableView.reloadData()
      }
      
      if isInitialSetUp {
        reactor?.action.onNext(.viewWillAppearForBookclip)
        carouselView.restartAll()
      }
    }
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: false)
    if hasAlreadyPreloadSetup { return }
    hasAlreadyPreloadSetup = true
    UIView.setAnimationsEnabled(false)
    searchController.isActive = true
    searchController.isActive = false
    UIView.setAnimationsEnabled(true)
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    carouselView.pauseAutoScroll()
    navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  // MARK: - Layout
  /// 이게 그 바이블 헤더가 폰 작은거 SE같은거일 때는 안보여서 이렇게 좀 스크롤 LayoutGuide 활용해서 래핑해서 한거야!
  /// 기억하자. 스크롤 빼면안되! 화면작은거 생각해
  public override func layoutUI() {
    view.addSubview(scrollView)
    let sc = scrollView.contentLayoutGuide
    [tags, carouselView, titleAndSubtitleView, bibleInformation, tableView].forEach(scrollView.addSubview)
    addReversedGradientView(fromSuperView: scrollView)
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      
      sc.topAnchor.constraint(equalTo: scrollView.topAnchor),
      sc.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      sc.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      sc.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
    ])
    
    let tableViewBottom = tableView.bottomAnchor.constraint(equalTo: sc.bottomAnchor)
    tableViewBottom.priority = .init(777)
    
    defaultConstraints = [
      carouselView.topAnchor.constraint(equalTo: sc.topAnchor),
      carouselView.heightAnchor.constraint(equalToConstant: 220),
      titleAndSubtitleView.topAnchor.constraint(equalTo: carouselView.bottomAnchor, constant: 8),
      titleAndSubtitleView.heightAnchor.constraint(equalToConstant: 91),
      bibleInformation.topAnchor.constraint(equalTo: titleAndSubtitleView.bottomAnchor, constant: 10),
      bibleInformation.centerXAnchor.constraint(equalTo: sc.centerXAnchor),
      
      tableView.topAnchor.constraint(equalTo: titleAndSubtitleView.bottomAnchor, constant: 16),
      tableView.heightAnchor.constraint(equalToConstant: 500),
      tableViewBottom
    ]
    
    expandedConstraints = [
      tableView.topAnchor.constraint(equalTo: tags.bottomAnchor, constant: 0),
      tableView.bottomAnchor.constraint(equalTo: sc.bottomAnchor)
    ] + makeReversedGradentViewConstriants { reversedGradientView in
      return [
        reversedGradientView.leadingAnchor.constraint(equalTo: sc.leadingAnchor),
        reversedGradientView.topAnchor.constraint(equalTo: tags.bottomAnchor),
        reversedGradientView.trailingAnchor.constraint(equalTo: sc.trailingAnchor),
        reversedGradientView.heightAnchor.constraint(equalToConstant: 16)
      ]
    }
    
    NSLayoutConstraint.activate(defaultConstraints)
    
    NSLayoutConstraint.activate([
      tags.leadingAnchor.constraint(equalTo: sc.leadingAnchor, constant: 16),
      tags.topAnchor.constraint(equalTo: sc.topAnchor, constant: 7),
      tags.trailingAnchor.constraint(lessThanOrEqualTo: sc.trailingAnchor, constant: -16),
      
      carouselView.leadingAnchor.constraint(equalTo: sc.leadingAnchor),
      carouselView.trailingAnchor.constraint(equalTo: sc.trailingAnchor),
      titleAndSubtitleView.leadingAnchor.constraint(equalTo: sc.leadingAnchor, constant: 16),
      titleAndSubtitleView.trailingAnchor.constraint(equalTo: sc.trailingAnchor, constant: -16),
      tableView.leadingAnchor.constraint(equalTo: sc.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: sc.trailingAnchor)
    ])
  }

  // MARK: - Helpers
  public func bind(reactor: BibleHomeReactor) {
    reactor.state.map { $0.oldTestamentExpanded }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] expended in
        if expended {
          self?.showOldTestamentBooks()
        } else {
          self?.oldTestamentTagsHide?()
          if !reactor.oldTestamentExpended && !reactor.newTestamentExpended {
            self?.isExpanded = false
          }
        }
        self?.tableView.reloadSections(IndexSet(integer: 0), with: .none)
      }).disposed(by: disposeBag)
    
    reactor.state.map { $0.newTestamentExpanded }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] expended in
        if expended {
          self?.showNewTestamentBooks()
        } else {
          self?.newTestamentTagsHide?()
          if !reactor.oldTestamentExpended && !reactor.newTestamentExpended {
            self?.isExpanded = false
          }
        }
        self?.tableView.reloadSections(IndexSet(integer: 1), with: .none)
      }).disposed(by: disposeBag)
    
    /// 터치 할 때
    reactor.state
      .compactMap { $0.updatableIndexPath }
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] indexPath in
        guard let self else { return }
        if indexPath.section == 0 {
          let cell = tableView.cellForRow(at: indexPath) as? OldTestamentOfBookAccordionCell
          tableView.performBatchUpdates { cell?.configure(with: reactor.item(indexPath)) }
        } else {
          let cell = tableView.cellForRow(at: indexPath) as? NewTestamentOfBookAccordionCell
          tableView.performBatchUpdates { cell?.configure(with: reactor.item(indexPath)) }
        }
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.shouldReloadForClip }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] shouldReload in
        guard let self else { return }
        guard shouldReload else { return }
        let currentClip = reactor.currentState.currentClip
        guard let updatedBookclip = reactor.currentState.updatedClip else {
          assertionFailure("북클립 업데이트 안됬나봄?")
          return
        }
        
        var currentIndexPath: IndexPath?
        var updatedIndexPath: IndexPath?
        if updatedBookclip.testament == .old {
          guard let index = reactor.currentState
            .oldTestamentItems.firstIndex(where: { $0.bookTitle == updatedBookclip.book})
          else { assertionFailure("1. index를 찾아야하지만 찾지 못함"); return }
          updatedIndexPath = IndexPath(row: index, section: 0)
        } else {
          guard let index = reactor.currentState
            .newTestamentItems.firstIndex(
              where: { $0.bookTitle == updatedBookclip.book })
          else { assertionFailure("1. index를 찾아야하지만 찾지 못함"); return }
          updatedIndexPath = IndexPath(row: index, section: 1)
        }
        
        if currentClip.testament == .old {
          guard let index = reactor.currentState.oldTestamentItems.firstIndex(
            where: { $0.bookTitle == currentClip.book })
          else { assertionFailure("1. index를 찾아야하지만 찾지 못함"); return }
          currentIndexPath = IndexPath(row: index, section: 0)
        } else {
          guard let index = reactor.currentState.newTestamentItems.firstIndex(
            where: { $0.bookTitle == currentClip.book })
          else { assertionFailure("1. index를 찾아야하지만 찾지 못함"); return }
          currentIndexPath = IndexPath(row: index, section: 1)
        }
        
        guard
          let currentIndexPath, let updatedIndexPath
        else { assertionFailure("여기서 현재 클립, 최근 클립 상태 두 개의 인덱스가 나와야함. 그러나 찾을 수 없음"); return }
        
        let isUserRecentlyWatchedTestamentChanged = currentClip.testament != updatedBookclip.testament
        if isUserRecentlyWatchedTestamentChanged {
          /// 이 경우엔 구약은 안 펼쳐져있고 구약을 본 상태(클립은 구약 헤더에 표시) + 신약이 펼쳐져 있는 상태에서 신약의 특정 챕터를 본 경우
          ///
          /// reloadRows만 하게된다면 구약의 헤더뷰 reolad하는 테이블뷰 refresh 함수가 없음.
          /// 그래서 섹션을 업데이트 해야함
          ///
          /// 섹션 간혹가다가 헤더 리로드 안부르는거같아..ㅠ
          DispatchQueue.main.async {
//            self.tableView.reloadSections(
//              IndexSet([currentIndexPath.section, updatedIndexPath.section]),
//              with: .automatic)
            self.tableView.reloadData()
          }
        } else {
          
          /// 위 경우 안하고 단순히 이렇게만 하면
          /// 구약에서 북클립 + 헤더만 보일때
          /// 신약에선 expanded된 후 특정한 신갹 북 - chapter 읽고 바이블 홈으로 올 때,
          /// 구약의 헤더 configure호출이 안됨.
          ///
          /// 구약 - 구약 / 신약 - 신약 이 경우엔 렌더링 비용 최소화 하고자 이렇게 함.
          DispatchQueue.main.async {
            self.tableView.reloadRows(
              at: [currentIndexPath, updatedIndexPath],
              with: .automatic)
          }
        }
      }).disposed(by: disposeBag)
  }
  
  func isExpandedUpdate(with flag: Bool) {
    isExpanded = flag
  }
  
  private func makeTags() -> [UIView] {
    let tag1 = IconTextWithClearTag(showClearIcon: true).then {
      $0.configure(icon: .asset(.hambergerMenu), text: "구약")
      $0.tap = { [weak self] in self?.reactor?.action.onNext(.oldTestamentBooksShow) }
    }
    let tag2 = IconTextWithClearTag().then {
      $0.configure(icon: .asset(.oldTestamentBook2Small), text: "39 Books", shouldHighlightLeadingNumber: true)
    }
    let tag3 = IconTextWithClearTag(showClearIcon: true).then {
      $0.configure(icon: .asset(.hambergerMenu), text: "신약")
      $0.tap = { [weak self] in self?.reactor?.action.onNext(.newTestamentBooksShow) }
    }
    let tag4 = IconTextWithClearTag().then {
      $0.configure(icon: .asset(.newTestamentBook2Small), text: "27 Books", shouldHighlightLeadingNumber: true)
    }
    
    oldTestamentTagsShow = {
      tag1.isHidden = false
      tag2.isHidden = false
    }
    oldTestamentTagsHide = {
      tag1.isHidden = true
      tag2.isHidden = true
    }
    newTestamentTagsShow = {
      tag3.isHidden = false
      tag4.isHidden = false
    }
    newTestamentTagsHide = {
      tag3.isHidden = true
      tag4.isHidden = true
    }
    
    oldTestamentTagsHide?()
    newTestamentTagsHide?()
    return [tag1, tag2, tag3, tag4]
  }
}

// MARK: - UISearchBarDelegate
extension BibleHomeViewController: UISearchBarDelegate {
  public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    searchController.isActive = false
    self.navigationItem.prompt = nil
    
    /// 에후..
    ///
    /// 이거 안하면 아이패드에서만 이 화면 -> SearchController로 전환할 때 맨 좌측 위에 서치바가 살짝 pop over되서 나왔다
    /// 사라지는 문제 발생. 그리고 그 서치바 뭉퉁그려진 객체가 searchBar의 becomeFirstResponder를 먹어버림 무엇.
    self.navigationItem.titleView = nil
    
    flowDependencies.showSearchPage()
  }
}
