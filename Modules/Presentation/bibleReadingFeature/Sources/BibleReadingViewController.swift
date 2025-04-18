//
//  BibleReadingViewController.swift
//  BibleContentFeature
//
//  Created by 양승현 on 2/14/25.
//

import UIKit
import Common
import RxSwift
import ReactorKit
import DomainEntity
import DesignSystem
import CoreInterface
import DesignSystemItems
import BibleReadingInterface

/// 이게 화면 전환할때 두번씩 호출되 보이는 이유가 있을수있음.
/// 이거 패이징 처리해서 앞면, 뒷면을 같은 화면으로 해 둬가지고 그럼 ㅋㅅㅋ
/// 아마 뺐을텐데? 안보일듯?
public final class BibleReadingViewController: BaseViewController, View {
  public typealias Reactor = BibleReadingReactor
  public typealias BySleepTimer = Bool
  
  // MARK: - Properties
  private(set) var bibleReadingView = BibleReadingView(frame: .zero)
  
  private var bibleReadingViewAdapter: BibleReadingViewAdapter!
  
  private var titleViewDisplayAnimator: UIViewPropertyAnimator?
  
  public var disposeBag: DisposeBag = .init()
  
  private(set) var sleepTimerExecutingView: SleepTimerExecutingView!
  
  private(set) lazy var scrollToTopView = UIView(frame: .zero).then {
    $0.setAutoLayout()
    $0.setRadius(1, withSpecificPositions: [.leftTop, .leftBottom])
    $0.backgroundColor = .palette(.title)
    $0.alpha = 0
  }
  
  private lazy var scrollToTopViewForUserInteraction = UIView(frame: .zero).then {
    $0.setAutoLayout()
    $0.backgroundColor = .clear
    let tap = UITapGestureRecognizer(target: self, action: #selector(didTapScrollToTopView))
    $0.addGestureRecognizer(tap)
  }
  
  private(set) var flowDependencies: BibleReadingFlowDependencies?
  
  private var viewWillAppearBySettingOrNoteView = false
  
  private(set) var scrollSaveTimer: Timer?
  
  private var entryBySleepAudioPlay: Bool
  
  private(set) var sleepAudioPlayer: BibleSleepAudioPlayerProtocol!
  
  private var panGesture: UIPanGestureRecognizer!
  
  /// 터치 지연됨. 생각보다 네비 화면전환보다 글자 보여지는게 빨라서 스크롤이 바로바로 안되는 느낌이들어
  /// 애니메이션으로 쪼금 자연스레 보여주자!
  private var isInitialViewWillAppearEntry = false
  
  // MARK: - Handlers
  private(set) var colorAddCompletion: ((BibleVerseHighlightItem) -> Void)?
  
  public weak var delegate: BibleReadingViewControllerDelegate?
  
  private var sleepAudioPlayerFactory: ((BibleSleepAudioPlayDataSource) -> BibleSleepAudioPlayerProtocol?)?
  
  // MARK: - Lifecycle
  public init(
    flowDependencies: BibleReadingFlowDependencies?,
    entryBySleepAudioPlay: Bool,
    delegate: BibleReadingViewControllerDelegate?,
    sleepAudioPlayerFactory: ((BibleSleepAudioPlayDataSource) -> BibleSleepAudioPlayerProtocol?)?
  ) {
    self.sleepAudioPlayerFactory = sleepAudioPlayerFactory
    self.delegate = delegate
    self.entryBySleepAudioPlay = entryBySleepAudioPlay
    self.flowDependencies = flowDependencies
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    /// swipe, pan
    panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    view.addGestureRecognizer(panGesture)
    view.bringSubviewToFront(scrollToTopView)
    view.bringSubviewToFront(scrollToTopViewForUserInteraction)
    bibleReadingView.alpha = 0
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    /// present면 호출안됨
    if viewWillAppearBySettingOrNoteView {
      viewWillAppearBySettingOrNoteView = false
      return
    }
    
    reactor?.action.onNext(.updatedOffset(
      offsetY: bibleReadingView.contentOffset.y,
      contentSizeHeight: bibleReadingView.contentSize.height,
      visibleSizeHeight: bibleReadingView.bounds.height
    ))
    startScrollTracking()
    
    /// 화면 보여질때마다 갱신해야함. 나의 활동에서 하트 지우면 여기에서 도 하트가 지워져 있어야 하기 때문임.
    /// 그리고 하트가 지워지면, contentSize가 달라져 이상하게 그래서 스크롤 바운싱이 여기서도 뜨네
    /// 맨 위로 스크롤해야함
    reactor?.action.onNext(.viewDidLoad)
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    releaseScrollSaveTimer()
    bibleReadingView.alpha = 1
    if reactor?.currentState.isExecutingAudioMode == true {
      reactor?.action.onNext(.sleepAudioCanceldByUser(elapsedSeconds: 0))
    }
    if viewWillAppearBySettingOrNoteView, reactor?.currentState.isExecutingAudioMode == true {
      ToastController.shared.showToast(
        message: "다른 화면으로 이동하여 오디오가 자동으로 종료됩니다.",
        position: .center,
        type: .warning)
    }
  }
  
  // MARK: - Layout
  public override func layoutUI() {
    super.layoutUI()
    [scrollToTopView, scrollToTopViewForUserInteraction].forEach(view.addSubview)
    
    NSLayoutConstraint.activate([
      scrollToTopView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
      scrollToTopView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
      scrollToTopView.widthAnchor.constraint(equalToConstant: 3),
      scrollToTopView.heightAnchor.constraint(equalToConstant: 27),
      
      scrollToTopViewForUserInteraction.topAnchor.constraint(equalTo: scrollToTopView.topAnchor),
      scrollToTopViewForUserInteraction.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollToTopViewForUserInteraction.widthAnchor.constraint(equalToConstant: 24),
      scrollToTopViewForUserInteraction.heightAnchor.constraint(equalToConstant: 72)
    ])
  }
  
  // MARK: - Bind
  // swiftlint:disable:next cyclomatic_complexity
  // swiftlint:disable:next function_body_length
  public func bind(reactor: BibleReadingReactor) {
    reactor.state
      .map { $0.bookChapterVerseName }
      .distinctUntilChanged()
      .filter { !$0.isEmpty }
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] title in
        self?.delegate?.provideNavigationTitle(title)
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.shouldReload }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] shouldReload in
        guard let self else { return }
        
        /// 화면 보여질때마다 갱신해야함. 나의 활동에서 하트 지우면 여기에서도 하트가 지워져 있어야 하기 때문임.
        /// 그리고 하트가 지워지면, contentSize가 달라져 이상하게 그래서 스크롤 바운싱이 여기서도 뜨네
        /// 맨 위로 스크롤해야함
        guard shouldReload else { return }
        bibleReadingView.reloadData()
        if bibleReadingView.contentOffset != .zero {
          bibleReadingView.setContentOffset(.zero, animated: false)
        }
        
        if !isInitialViewWillAppearEntry {
          isInitialViewWillAppearEntry = true
          bibleReadingView.transform = CGAffineTransform(translationX: 2, y: 0)
          bibleReadingView.alpha = 0
          UIView.animate(
            withDuration: 0.25,
            delay: 0.13,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 1,
            options: [.curveEaseOut],
            animations: { [weak self] in
              guard let self else { return }
              self.bibleReadingView.transform = .identity
              self.bibleReadingView.alpha = 1
            },
            completion: nil
          )
        }
        
        print("뷰딛로드에서 먼저 데이터를 받아와야만 오디오 실행도 가능함")
        /// 자동으로 오디오 플레이어에 의해 다음장으로 넘어갔을 때 호출됨
        if entryBySleepAudioPlay {
          prepareSleepAudioPlay()
          reactor.action.onNext(.sleepAudioPlayBySleepAudioPlayer)
        }
      }).disposed(by: disposeBag)
    
    reactor.state
      .compactMap { $0.updatedhighlight }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] highlightItem in
        self?.colorAddCompletion?(highlightItem)
        self?.colorAddCompletion = nil
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.updatedNoteCompletion }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] hasCompleted in
        guard let self, hasCompleted else { return }
        guard let shouldUpdateIndex = reactor.currentState.updatedNoteIndex else {
          assertionFailure("노노 왜 안돼?"); return
        }
        let indexPath = IndexPath(item: shouldUpdateIndex, section: 0)
        UIView.performWithoutAnimation {
          self.bibleReadingView.reloadItems(at: [indexPath])
        }
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.errorMessage }
      .distinctUntilChanged()
      .filter { !$0.isEmpty }
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { errorMessage in
        if errorMessage == "" { return }
        ToastController.shared.showToast(message: errorMessage, position: .navBarBottom, type: .error)
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.updatedFontHandlingCompletion }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] hasCompelted in
        guard let self else { return }
        guard hasCompelted else { return }
        handleUpdatedFont()
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.hasHandledReadCompletion }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] hasCompelted in
        guard let self else { return }
        guard hasCompelted else { return }
        let contentsControlView = bibleReadingView
          .visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter)
          .filter { $0 is BibleContentControlViewAnimationCaller }
          .first as? BibleContentControlViewAnimationCaller
        
        let savedState = reactor.currentState.readCompletionSaveState
        if let controlView = contentsControlView {
          switch savedState {
          case .saved:
            controlView.savedCompletionAnimation()
          case .notSaved:
            controlView.noteSavedAniamtion()
          }
        } else { assertionFailure("사용자가 스크롤해서 올리거나 controlView인스턴스 못찾음") }
        
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.audioPlayTimeDoneForPlayOnce }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { audioPlayTimeDoneForPlayOnce in
        guard audioPlayTimeDoneForPlayOnce else { return }
        ToastController.shared.showToast(message: "지정된 시간이 모두 지나 오디오가 종료됩니다", type: .success)
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.shouldStartAudioPlay }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] shouldStartAudioPlay in
        guard let self else { return }
        guard shouldStartAudioPlay else { return }
        ToastController.shared.showToast(
          message: "무음 모드일 경우 오디오가 들리지 않을 수 있어요.",
          position: .navBarBottom,
          type: .warning)
        self.prepareSleepAudioPlay()
        self.sleepAudioPlayer.configure(totalDuration: reactor.currentState.remainingaudioPlayTime)
        self.sleepAudioPlayer.resume()
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.shouldPlayOtherChapter }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] shouldPlayOtherChapter in
        guard let self else { return }
        guard shouldPlayOtherChapter else { return }
        
        if reactor.currentState.wannaPlayPrevChapter {
          delegate?.handlePrevPageShowing(true)
        } else {
          delegate?.handleNextPageShowing(true)
        }
        sleepAudioPlayer.releaseAllAudio()
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.audioPlayCancelByUserSetCompletion }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] audioPlayCancelByUserSetCompletion in
        guard let self else { return }
        guard audioPlayCancelByUserSetCompletion else { return }
        deactiveAudioPlayFlow()
      }).disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  func releaseSleepTimerExecutingView() {
    sleepTimerExecutingView = nil
  }
  
  func initSleepTimerExecutingView() {
    sleepTimerExecutingView = .init()
    sleepTimerExecutingView.clearButtonTap = { [weak self] in
      self?.reactor?.action.onNext(.sleepAudioCanceldByUser(elapsedSeconds: 0))
      ToastController.shared.showToast(message: "오디오가 종료됬습니다", type: .success)
    }
  }
  
  func setViewWillAppearBySettingOrNoteView(_ bool: Bool) {
    viewWillAppearBySettingOrNoteView = bool
  }
  
  func initSleepAudioPlayer() {
    guard let reactor else {
      assertionFailure("리엑터가 사라질 일은 이 뷰컨이 종료되는건데..?")
      ToastController.shared.showToast(message: "성경 화면을 나가면 오디오를 재생할 수 없습니다.", type: .error)
      return
    }
    sleepAudioPlayer = sleepAudioPlayerFactory?(reactor)
  }
  
  func releaseSleepAudioPlayer() {
    sleepAudioPlayer = nil
  }
  
  func releaseScrollSaveTimer() {
    print("타이머 멈추거라")
    scrollSaveTimer?.invalidate()
    scrollSaveTimer = nil
  }
  
  func setPanGesture(isEnabled: Bool) {
    panGesture.isEnabled = isEnabled
  }
  
  func setColorAddCompletion(_ completion: @escaping (BibleVerseHighlightItem) -> Void) {
    colorAddCompletion = completion
  }
  
  func setScrollSaveTimer(
    withTimeInterval: TimeInterval,
    repeats: Bool,
    _ tasker: @escaping @Sendable (Timer) -> Void
  ) {
    scrollSaveTimer = Timer.scheduledTimer(withTimeInterval: withTimeInterval, repeats: repeats, block: tasker)
  }
  
  private func configureUI() {
    bibleReadingViewAdapter = BibleReadingViewAdapter(
      dataSource: reactor,
      delegate: self,
      collectionView: bibleReadingView)
    view.backgroundColor = .palette(.appearance)
    bibleReadingView.layout(from: view)
  }
  
  func setScrollToTopView(alpha: CGFloat) {
    scrollToTopView.alpha = alpha
  }
}
