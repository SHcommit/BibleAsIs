//
//  BibleSearchViewController.swift
//  BibleSearchFeature
//
//  Created by 양승현 on 2/20/25.
//

import UIKit
import RxSwift
import ReactorKit
import DesignSystem
import DomainEntity
import BibleSearchInterface
import DesignSystemInterface

public final class BibleSearchViewController: BaseViewController, View {
  public typealias Reactor = BibleSearchReactor
  
  // MARK: - Properties
  private lazy var resultViewController: BibleSearchResultViewController? = (flowDependencies
    .makeSearchResultViweController() as? BibleSearchResultViewController)
  
  private lazy var searchController = UISearchController(
    searchResultsController: resultViewController)
  
  private let upperContainerView = UIView(frame: .zero).then {
    $0.isUserInteractionEnabled = true
    $0.setAutoLayout()
  }
  
  private let recentSearchKeywordsHeaderView = UILabel(frame: .zero).then {
    $0.setAutoLayout()
    $0.text = "최근 검색어"
    $0.font = .appleSDGothicNeo(.bold, size: 20)
    $0.textColor = .palette(.title)
    $0.numberOfLines = 1
    $0.textAlignment = .left
  }
  
  private let recentSearchKeywordsView = UICollectionView.makeBibleRecentSearchKeywordsView(frame: .zero)
  
  private var recentSearchKeywordsViewAdapter: BibleRecentSearchKeywordsViewAdapter!
  
  private let searchHistoryHeaderView = UILabel(frame: .zero).then {
    $0.setAutoLayout()
    $0.text = "검색 히스토리"
    $0.font = .appleSDGothicNeo(.bold, size: 20)
    $0.textColor = .palette(.title)
    $0.textAlignment = .left
  }
  
  private let searchHistoryView = BibleVersesTimelineView(forHeartUsage: false).then {
    $0.setAutoLayout()
    $0.verticalScrollIndicatorInsets = .init(top: 154.667 + 16, left: 0, bottom: 7+7+7, right: 0)
  }
  
  private var upperContainerViewHeight: CGFloat! = 154.667
  
  private var initialOffsetY: CGFloat!
  
  private var headerHeightConstraint: NSLayoutConstraint!
  
  private let searchTextSubject = PublishSubject<String>()
  
  public override var canBecomeFirstResponder: Bool {
    true
  }
  
  public var disposeBag: RxSwift.DisposeBag = .init()
  
  private var flowDependencies: BibleSearchFlowDependencies
  
  private var hasAlreadyPreloadSetup = false
  
  // MARK: - Lifecycle
  public init(flowDependencies: BibleSearchFlowDependencies) {
    self.flowDependencies = flowDependencies
    super.init(nibName: nil, bundle: nil)
    hidesBottomBarWhenPushed = true
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) { nil }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.prompt = nil
    view.backgroundColor = .palette(.appearance)
    definesPresentationContext = true
    /// 탭, 드래그 가로채서 키보드 내려가게 하자 . 편의상
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    tapGesture.cancelsTouchesInView = false
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(hideKeyboard))
    panGesture.cancelsTouchesInView = false
    [panGesture, tapGesture].forEach(view.addGestureRecognizer)
    recentSearchKeywordsViewAdapter = BibleRecentSearchKeywordsViewAdapter(
      dataSource: reactor,
      delegate: self,
      collectionView: recentSearchKeywordsView)
    searchHistoryView.versesTimelineViewDelegate = self
    configureSearchController()
    
    showGradientView()

    headerHeightConstraint = upperContainerView.heightAnchor.constraint(
      equalToConstant: upperContainerViewHeight)
    headerHeightConstraint.isActive = true
    
    searchHistoryView.contentInset = UIEdgeInsets(
      top: upperContainerViewHeight, left: 0, bottom: 0, right: 0)
    searchHistoryView.contentOffset = CGPoint(x: 0, y: -upperContainerViewHeight)
    
    reactor?.action.onNext(.refresh)
    resultViewController?.wannaDisappearKeyboard = { [weak self] in
      guard let self else { return }
      hideKeyboard()
    }
    resultViewController?.didTapForReadingBibleReadingPage = { [weak self] in
      guard let self else { return }
      reactor?.action.onNext(.refresh)
    }
    navigationItem.titleView = searchController.searchBar
    searchController.delegate = self
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // 느리다쿤
    if !hasAlreadyPreloadSetup {
      hasAlreadyPreloadSetup = true
      UIView.setAnimationsEnabled(false)
      searchController.isActive = true
      searchController.isActive = false
      UIView.setAnimationsEnabled(true)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
        self.searchController.isActive = true
      })
    }
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    searchController.searchBar.resignFirstResponder()
    searchController.isActive = false
    if searchController.searchBar.showsCancelButton {
      searchController.searchBar.setShowsCancelButton(false, animated: true)
    }
  }
  
  // MARK: - Layout
  public override func layoutUI() {
    [recentSearchKeywordsHeaderView,
     recentSearchKeywordsView, searchHistoryHeaderView].forEach(upperContainerView.addSubview(_:))
    NSLayoutConstraint.activate([
      recentSearchKeywordsHeaderView.leadingAnchor.constraint(
        equalTo: upperContainerView.leadingAnchor,
        constant: 16),
      recentSearchKeywordsHeaderView.topAnchor.constraint(equalTo: upperContainerView.topAnchor, constant: 12),
      recentSearchKeywordsHeaderView.trailingAnchor.constraint(
        equalTo: upperContainerView.trailingAnchor,
        constant: -16),
      recentSearchKeywordsView.leadingAnchor.constraint(equalTo: upperContainerView.leadingAnchor),
      recentSearchKeywordsView.topAnchor.constraint(
        equalTo: recentSearchKeywordsHeaderView.bottomAnchor,
        constant: 16),
      recentSearchKeywordsView.trailingAnchor.constraint(equalTo: upperContainerView.trailingAnchor),
      recentSearchKeywordsView.heightAnchor.constraint(equalToConstant: 25),
      
      searchHistoryHeaderView.leadingAnchor.constraint(equalTo: upperContainerView.leadingAnchor, constant: 16),
      searchHistoryHeaderView.topAnchor.constraint(equalTo: recentSearchKeywordsView.bottomAnchor, constant: 42),
      searchHistoryHeaderView.trailingAnchor.constraint(equalTo: upperContainerView.trailingAnchor, constant: -16),
      searchHistoryHeaderView.bottomAnchor.constraint(equalTo: upperContainerView.bottomAnchor, constant: -7)
    ])
    
    [searchHistoryView, upperContainerView].forEach(view.addSubview(_:))
    NSLayoutConstraint.activate([
      upperContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      upperContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      upperContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      
      searchHistoryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      searchHistoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      searchHistoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      searchHistoryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
  }
  
  // MARK: - Bind
  public func bind(reactor: BibleSearchReactor) {
    searchTextSubject
      .distinctUntilChanged()
      .throttle(.milliseconds(777/2), scheduler: MainScheduler.instance)
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] query in
        self?.resultViewController?.update(textDidChange: query)
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.unexpectedErrorOccured }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { unexpectedErrorMsg in
        guard unexpectedErrorMsg.count > 0 else { return }
        ToastController.shared.showToast(message: unexpectedErrorMsg, type: .error)
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.recentlySearchedQueryRefresh }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        self?.recentSearchKeywordsView.reloadData()
      }).disposed(by: disposeBag)

    reactor.state
      .map { $0.timelineHistoryRefresh }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        self?.searchHistoryView.configure(
          hasInitiallyFetched: reactor.currentState.hasInitiallyFetched, reactor.currentState.timelineHistorySections,
          items: reactor.currentState.timelineHistoryItems)
        self?.searchHistoryView.reloadData()
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.deletedTimelineHistory ?? -1 }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] sectionIndex in
        if sectionIndex == -1 { return }
        guard let self else { return }
        searchHistoryView.configure(
          hasInitiallyFetched: reactor.currentState.hasInitiallyFetched,
          reactor.currentState.timelineHistorySections,
          items: reactor.currentState.timelineHistoryItems)
        
        if reactor.currentState.timelineHistorySections.count == 0 {
          searchHistoryView.reloadData()
          return
        }
        /// 이거 deleteSections 으로 삭제하면  그 다음 셀들 indexpath가 새로반영 안됨.
        /// 셀 하나 삭제하면 그 아래 아래아래.. 전부 다 tap 으로 캡쳐해둔거 이거 section 다 다시 갱신해야함 근데 안되니까 에러남..
        searchHistoryView.performBatchUpdates({
          self.searchHistoryView.deleteSections(IndexSet(integer: sectionIndex))
        }, completion: { _ in
          self.searchHistoryView.layoutIfNeeded()
        })
      }).disposed(by: disposeBag)
        
    /// 확인 완료
    reactor.state
      .map { $0.deletedRecentlyQueryIndex ?? -1 }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] index in
        guard let self else { return }
        if index == -1 { return }
        if reactor.currentState.recentlySearchedQueries.queries.isEmpty {
          recentSearchKeywordsView.reloadData()
          return
        }
        recentSearchKeywordsView.performBatchUpdates { [weak self] in
          self?.recentSearchKeywordsView.deleteItems(at: [IndexPath.init(item: index, section: 0)])
        }
      }).disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  @objc private func hideKeyboard() {
    if searchController.searchBar.isFirstResponder {
      searchController.searchBar.endEditing(true)
    }
  }
  
  private func configureSearchController() {
    
    navigationItem.hidesSearchBarWhenScrolling = false
    searchController.searchBar.placeholder = "검색어 입력, 구절(창 1:7)"
    searchController.searchBar.keyboardType = .default
    searchController.modalPresentationStyle = .fullScreen
    
    /// 이걸 해야만 . 서치바를 타이틀에 넣었을때 서치바를 클릭할 때 내비바가 휙 하고 네비게이션 위로 안사라짐
    /// titleView로 등록했지만, searchController로 동작하게 한다면, 좌표계 없다고 판단해서 위로 숗 보내버릴 수 있게됨.
    /// (사용자가 서치바 터치하면 위로 올라가면서 화면에 안보임 )
    searchController.hidesNavigationBarDuringPresentation = false
    
    searchController.searchBar.searchBarStyle = .prominent
    searchController.searchBar.tintColor = .palette(.title)
    searchController.searchBar.searchTextField.font = .appleSDGothicNeo(.light, size: 14)
    searchController.searchBar.delegate = self
//    searchController.modalPresentationStyle = .fullScreen
    searchController.searchBar.setValue("취소", forKey: "cancelButtonText")
    searchController.searchBar.searchTextField.clearButtonMode = .never
    
    let item = UIBarButtonItem.makeBackBarButtonItem(self, action: #selector(didTapBackButton))
    navigationItem.setLeftBarButton(item, animated: true)
    
    let textField = searchController.searchBar.searchTextField
    textField.spellCheckingType = .no
    
    searchController.searchBar.searchTextField.becomeFirstResponder()
    if #available(iOS 13, *) {
      searchController.obscuresBackgroundDuringPresentation = false
    } else {
      searchController.dimsBackgroundDuringPresentation = false
    }
  }
}

// MARK: - BibleVerseTimelineViewDelegate
extension BibleSearchViewController: BibleVerseTimelineViewDelegate {
  /// 미사용
  public func didTapHeart(cell: UICollectionViewCell?, testament: DomainEntity.BibleTestament) { }
  
  public func didTapAllClear(for header: UICollectionReusableView) {
    guard let section = searchHistoryView.indexPath(forSupplementaryView: header) else {
      assertionFailure("Self참조실패 왜 실패했는지 컬스택 확인좀!:\(header)"); return
    }

    reactor?.action.onNext(.specificHistoriesDelete(section.section))
  }
  
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    if searchController.searchBar.isFirstResponder {
      searchController.searchBar.endEditing(true)
      searchController.isActive = false
    }
  }
  
  public func scrollViewDidScroll(with offsetY: CGFloat) {
    if upperContainerViewHeight == nil { return }
    
    let effectiveOffset = -(offsetY + upperContainerViewHeight)
    if effectiveOffset < upperContainerViewHeight {
      if !upperContainerView.isHidden {
        upperContainerView.transform = CGAffineTransform(translationX: 0, y: effectiveOffset)
      }
    }
    if abs(effectiveOffset) >= upperContainerViewHeight, !upperContainerView.isHidden {
      upperContainerView.isHidden = true
    } else if abs(effectiveOffset) < upperContainerViewHeight, upperContainerView.isHidden {
      upperContainerView.isHidden = false
    }
    view.layoutIfNeeded()
  }
}

// MARK: - BibleRecentSearchKeywordsAdapterDelegate
extension BibleSearchViewController: BibleRecentSearchKeywordsAdapterDelegate {
  public func showBibleContentPage(_ cell: UICollectionViewCell) {
    guard let indexPath = recentSearchKeywordsView.indexPath(for: cell) else { return }
    
    // 바이블 상세 화면으로 이동하는게 아니라 이걸 검색 해줘야함.
    // print("바이블 컨텐츠 살펴보기 이동해야함 바이블 컨텐츠 화면 상세화면으로: \(indexPath.item)")]
    // 아래처럼 말이지 ㅎㅅㅎ
    
    if reactor?.item(indexPath: indexPath) == "" { return }
    searchController.searchBar.text = reactor?.item(indexPath: indexPath)
    searchController.searchBar.delegate?.searchBar?(
      searchController.searchBar,
      textDidChange: searchController.searchBar.text ?? "")
    searchController.isActive = true
    searchController.searchBar.setShowsCancelButton(true, animated: true)
    searchController.searchResultsUpdater?.updateSearchResults(for: searchController)

  }
  
  public func deleteTag(_ cell: UICollectionViewCell) {
    guard let indexPath = recentSearchKeywordsView.indexPath(for: cell) else { return }
    reactor?.action.onNext(.tagDelete(indexPath.item))
  }
}

// MARK: - UISearchBarDelegate
extension BibleSearchViewController: UISearchBarDelegate {
  public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    if !searchBar.isFirstResponder {
      searchBar.becomeFirstResponder()
    }
  }
  
  public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    if searchBar.isFirstResponder == false {
      searchBar.becomeFirstResponder()
    }
    searchBar.setShowsCancelButton((searchText.count >= 1), animated: true)
    searchTextSubject.onNext(searchText)
  }
  
  public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = ""
    self.searchController.searchBar.setShowsCancelButton(false, animated: true)
    self.searchController.isActive = false
    self.hideKeyboard()
  }
  
  public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    if searchBar.text == nil || searchBar.text == "" {
      searchBar.setShowsCancelButton(false, animated: false)
    }
    return true
  }
}

extension BibleSearchViewController: UISearchControllerDelegate {
  public func presentSearchController(_ searchController: UISearchController) {
    searchController.searchBar.becomeFirstResponder()
  }
}
