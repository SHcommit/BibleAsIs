//
//  BibleReadingChecklistViewController.swift
//  BibleReadingChecklistFeature
//
//  Created by 양승현 on 3/1/25.
//

import UIKit
import RxSwift
import ReactorKit
import DesignSystem
import BibleReadingChecklistInterface

/// https://stackoverflow.com/questions/62668158/uicollectionviewcell-doesnt-fill-the-screen
/// 캬 내가 원했던거 : ]
public final class BibleReadingChecklistViewController: BaseViewController, View, BibleReadingChecklistHeroAnimatable {
  public typealias Reactor = BibleReadingChecklistReactor
  
  // MARK: - Properties
  private(set) var checkableDailyReadingView = UITableView.makeBibleReadingChecklistChecklistView(
    frame: .zero,
    style: .grouped)
  
  private(set) lazy var backButton = PaddingImageView(
    padding: .init(inset: 7),
    imageViewFactory: {
      $0.setImage(image: .asset(.xClear2)) 
      $0.contentMode = .scaleAspectFit
      $0.setAutoLayout()
    }
  ).then {
    $0.setAutoLayout()
    $0.isUserInteractionEnabled = true
    $0.backgroundColor = .palette(.clearButtonBgForHistory)
    $0.layer.cornerRadius = 24/2.0
    let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBack))
    $0.addGestureRecognizer(tap)
  }
  
  private lazy var blurNavigationView: UIView = makeBlurNaviView()
  
  private(set) var titleLabel = UILabel(frame: .zero).then {
    $0.setAutoLayout()
    $0.alpha = 0
    $0.textColor = .palette(.title)
    $0.font = .appleSDGothicNeo(.bold, size: 16)
    $0.textAlignment = .center
    $0.text = "데일리 성경 읽기 체크리스트"
  }
  
  private var titleViewDisplayAnimator: UIViewPropertyAnimator?
  
  private var checkableDailyReadingViewAdapter: CheckableBibleDailyReadingChecklistAdapter!
  
  public var disposeBag = DisposeBag()
  
  private(set) var isBlurVisible = false
  
  private(set) var hasDailyCardHeaderViewDisappeared = false
  
  private(set) var shouldCardHeaderExpand = false
  
  private var dismissCompletionHandler: (() -> Void)?
  
  public var initialLoadingCompletionHandler: (() -> Void)?
  
  private(set) var flowDependencies: BibleReadingChekclistFlowDependencies
  
  // MARK: - Lifecycle
  /// dismissCompletionhandler는 커스텀 dismiss hero aniamtor에게 알려줄 때 등등 사용해야 함.
  /// 커스텀 dismiss hero animatino이 처음 완료될 때 헨들러를 호출해야함.
  init(
    flowDependencies: BibleReadingChekclistFlowDependencies,
    dismissCompletionHandler: (() -> Void)?
  ) {
    self.flowDependencies = flowDependencies
    self.dismissCompletionHandler = dismissCompletionHandler
    super.init(nibName: nil, bundle: nil)
    hidesBottomBarWhenPushed = true
  }
  
  @available(*, deprecated)
  required public init?(coder: NSCoder) { nil }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .palette(.appearance)
    definesPresentationContext = true
    checkableDailyReadingViewAdapter = CheckableBibleDailyReadingChecklistAdapter(
      dataSource: reactor,
      delegate: self,
      tableView: checkableDailyReadingView)
    titleLabel.transform = .init(translationX: 0, y: titleLabel.font.lineHeight-7)
    titleLabel.isHidden = true
    showGradientView()
    reactor?.action.onNext(.viewDidLoad)
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    hideNavigationBar(withAnim: false)
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    backButton.setShadow(with: .normalComponent, cornerRadius: 24/2.0)
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    showNavigationBar(withAnim: true)
  }
  
  // MARK: - Layout
  public override func layoutUI() {
    [checkableDailyReadingView, backButton, titleLabel].forEach(view.addSubview)
    
    checkableDailyReadingView.setAutoLayout()
    NSLayoutConstraint.activate([
      checkableDailyReadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      checkableDailyReadingView.topAnchor.constraint(equalTo: view.topAnchor),
      checkableDailyReadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      checkableDailyReadingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      
      backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: (44-22)/2),
      backButton.widthAnchor.constraint(equalToConstant: 24),
      backButton.heightAnchor.constraint(equalToConstant: 24),
      
      titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
    ])
  }
  
  // MARK: - View
  public func bind(reactor: BibleReadingChecklistReactor) {
    reactor.state
      .map { $0.shouldRefresh }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] shouldRefresh in
        if shouldRefresh {
          self?.checkableDailyReadingView.reloadData()
          self?.initialLoadingCompletionHandler?()
        }
      }).disposed(by: disposeBag)
    
    reactor.state
      .compactMap { $0.expandableIndexPathUpdated }
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] expandableIndexPath in        
        guard let self else { return }
        let item = reactor.dailyReadingItem(row: expandableIndexPath.row)
        if reactor.isOldTestament(forIndexPath: expandableIndexPath) {
          typealias OldTestamentType = CheckableOldTestamentOfBookAccordionCell
          let cell = checkableDailyReadingView.cellForRow(at: expandableIndexPath) as? OldTestamentType
          self.checkableDailyReadingView.performBatchUpdates({
            cell?.configure(with: item)
          })
        } else {
          typealias NewTestamentType = CheckableNewTestamentOfBookAccordionCell
          let cell = checkableDailyReadingView.cellForRow(at: expandableIndexPath) as? NewTestamentType
          checkableDailyReadingView.performBatchUpdates {
            cell?.configure(with: item)
          }
          
        }
      }).disposed(by: disposeBag)
    
    reactor.state
      .compactMap { $0.toggableChapterRefreshBookByUpdating }
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] updatedBookIndexPath in
        guard let self else { return }
        
        UIView.performWithoutAnimation {
          self.checkableDailyReadingView.reloadRows(at: [updatedBookIndexPath], with: .automatic)
        }
        print("hiss")
//        UIView.setAnimationsEnabled(false)
//        self.checkableDailyReadingView.reloadRows(at: [updatedBookIndexPath], with: .none)
//        UIView.setAnimationsEnabled(true)
        
        // 이러면 좀 전체적으로 껌빡거림 리로드 하니까
//        self.checkableDailyReadingView.reloadRows(at: [updatedBookIndexPath], with: .automatic)
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.descriptionUpdate }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] updated in
        guard let self, updated else { return }
        /// 섹션 0이 보일 때 업데이트 하진 말자.. ( 툭 튀는 현상 있음 )
        /// 해결.
        let visibleIndexPaths = checkableDailyReadingView.indexPathsForVisibleRows ?? []
        guard visibleIndexPaths.contains(where: { $0.section == 1 && $0.row == 0}) else { return }
        print("hissssss")
        let indexPath = IndexPath(row: 0, section: 1)
        (checkableDailyReadingView
          .cellForRow(at: indexPath) as? BibleReadingChecklistDescriptionCell)?
          .configure(with: reactor.descriptionItem)
        UIView.performWithoutAnimation {
          self.checkableDailyReadingView.reloadSections(IndexSet(integer: 0), with: .none)
        }
        
      }).disposed(by: disposeBag)
  }
}

// MARK: - Helpers
extension BibleReadingChecklistViewController {
  public func shouldShowGradient() {
    showGradientView()
  }
  
  func setShouldCardHeaderExpand(with flag: Bool) {
    shouldCardHeaderExpand = flag
  }
  
  func setNavigationViewBlurAlpha(_ alpha: CGFloat) {
    blurNavigationView.alpha = alpha
  }
  
  func setBlurIsVisible(_ flag: Bool) {
    isBlurVisible = flag
  }
  
  func setDailyCardHeaderViewHasDisappeared(_ hasDisappeared: Bool) {
    hasDailyCardHeaderViewDisappeared = hasDisappeared
  }
  
  func handleCardHeaderViewWillDisplay() {
    let fontHeight = titleLabel.font.lineHeight
    titleViewDisplayAnimator?.stopAnimation(true)
    titleViewDisplayAnimator = UIViewPropertyAnimator(
      duration: 0.17,
      curve: .easeInOut,
      animations: { [weak self] in
        guard let self else { return }
        titleLabel.alpha = 0
        titleLabel.transform = .init(translationX: 0, y: fontHeight-7)
      })
    titleViewDisplayAnimator?.addCompletion { [weak self] _ in
      self?.titleLabel.isHidden = true
    }
    titleViewDisplayAnimator?.startAnimation()
  }
  
  func handleCardHeaderViewDisappear() {
    titleLabel.isHidden = false
    titleViewDisplayAnimator?.stopAnimation(true)
    titleViewDisplayAnimator = UIViewPropertyAnimator(
      duration: 0.17, curve: .easeInOut,
      animations: { [weak self] in
        guard let self else { return }
        titleLabel.transform = .identity
        titleLabel.alpha = 1
      })
    titleViewDisplayAnimator?.startAnimation()
  }
}

// MARK: - Actions
extension BibleReadingChecklistViewController {
  @objc private func didTapBack() {
    let blurV = BlurWithVibrancyView(
      blurStyle: .systemThickMaterial, vibrancyStyle: .fill
    ).then {
      view.addSubview($0)
      NSLayoutConstraint.activate([
        $0.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        $0.topAnchor.constraint(equalTo: view.topAnchor),
        $0.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        $0.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
    blurV.bringSubviewToFront(blurV)
    view.layoutIfNeeded()
    flowDependencies.dismissWhenBackTap(completion: dismissCompletionHandler)
  }
}
