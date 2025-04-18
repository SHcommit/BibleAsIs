//
//  BibleReadingPlanHome.swift
//  MyActivityFeature
//
//  Created by 양승현 on 3/1/25.
//

import Then
import UIKit
import RxSwift
import ReactorKit
import DesignSystem
import DesignSystemItems
import MyActivityInterface
import BibleMccCheyneChallengeInterface

public final class BibleReadingPlanHomeViewController: BaseViewController, View {
  public typealias Reactor = BibleReadingPlanHomeReactor
  
  // MARK: - Properties
  private lazy var mccCheyneViewController = flowDependencies.makeBibleMccCheyneChallengeViewController()

  private var mccCheyneView: UIView {
    mccCheyneViewController.view
  }
  
  private let bibleReadingChallengeTitleLabel = UILabel(frame: .zero).then {
    $0.setAutoLayout()
    $0.text = "일독 챌린지"
    $0.font = .appleSDGothicNeo(.bold, size: 20)
    $0.textAlignment = .left
    $0.textColor = .palette(.title)
  }
  
  private(set) var dailyReadingChallengeView = DailyChallengeCardView(frame: .zero).then {
    $0.setAutoLayout()
  }
  
  public var disposeBag: DisposeBag = DisposeBag()
  
  private(set) var frameForStartingCustomTransitionComponent: CGRect?
  
  private let flowDependencies: MyActivityCoordinatorFlowDependencies
  
  // MARK: - Lifecycle
  init(flowDependencies: MyActivityCoordinatorFlowDependencies) {
    self.flowDependencies = flowDependencies
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) { nil }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    let tap = UITapGestureRecognizer(target: self, action: #selector(didTapDailyReadingChallengeView))
    dailyReadingChallengeView.isUserInteractionEnabled = true
    dailyReadingChallengeView.addGestureRecognizer(tap)
    showGradientView()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    reactor?.action.onNext(.viewWillAppear)
    (mccCheyneViewController as? BibleMccCheyneRefreshable)?.reloadData()
  }
  
  // MARK: - LayoutUI
  public override func layoutUI() {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.contentInset = .zero
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.scrollIndicatorInsets = .zero
    scrollView.alwaysBounceVertical = true
    scrollView.alwaysBounceHorizontal = false
    
    if #available(iOS 11.0, *) {
      scrollView.contentInsetAdjustmentBehavior = .never
    } else {
      automaticallyAdjustsScrollViewInsets = false
    }
    view.addSubview(scrollView)
    let sc = scrollView.contentLayoutGuide
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      
      sc.topAnchor.constraint(equalTo: scrollView.topAnchor),
      sc.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      sc.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      sc.bottomAnchor.constraint(greaterThanOrEqualTo: scrollView.bottomAnchor)
    ])
    
    [
      mccCheyneView,
      bibleReadingChallengeTitleLabel,
      dailyReadingChallengeView
    ].forEach { scrollView.addSubview($0) }
    mccCheyneView.setAutoLayout()
    
    let dailyReadingChallengeViewBottomConstraint = dailyReadingChallengeView.bottomAnchor.constraint(
      equalTo: sc.bottomAnchor,
      constant: -20)
    dailyReadingChallengeViewBottomConstraint.priority = .init(777)
    
    let dailyReadingChallengeViewTrailingConstraint = dailyReadingChallengeView.trailingAnchor.constraint(
      equalTo: sc.trailingAnchor,
      constant: -16)
    dailyReadingChallengeViewTrailingConstraint.priority = .init(777)
    
    let mccCheyneViewTrailingConstriant = mccCheyneView.trailingAnchor.constraint(equalTo: sc.trailingAnchor)
    mccCheyneViewTrailingConstriant.priority = .init(777)
    
    NSLayoutConstraint.activate([
      mccCheyneView.topAnchor.constraint(equalTo: sc.topAnchor),
      mccCheyneView.leadingAnchor.constraint(equalTo: sc.leadingAnchor),
      mccCheyneViewTrailingConstriant,
      mccCheyneView.heightAnchor.constraint(
        equalToConstant: BibleMccCheyneChallengeConstraints.mccCheyneChallengeHeight),
      
      bibleReadingChallengeTitleLabel.topAnchor.constraint(equalTo: mccCheyneView.bottomAnchor, constant: 36),
      bibleReadingChallengeTitleLabel.leadingAnchor.constraint(equalTo: sc.leadingAnchor, constant: 16),
      bibleReadingChallengeTitleLabel.heightAnchor.constraint(
        equalToConstant: UIFont.appleSDGothicNeo(.bold, size: 20).lineHeight + 2),
      
      dailyReadingChallengeView.topAnchor.constraint(
        equalTo: bibleReadingChallengeTitleLabel.bottomAnchor,
        constant: 20),
      dailyReadingChallengeView.leadingAnchor.constraint(equalTo: sc.leadingAnchor, constant: 16),
      dailyReadingChallengeViewTrailingConstraint,
      dailyReadingChallengeView.heightAnchor.constraint(equalToConstant: DailyChallengeCardView.Height),
      
      dailyReadingChallengeViewBottomConstraint
    ])
  }
  
  // MARK: - Helpers
  public func setHidingDailyBibleChallengeView() {
    dailyReadingChallengeView.alpha = 0
  }
  
  public func setShowingDailyBibleChallengeView() {
    dailyReadingChallengeView.alpha = 1
  }
    
  // MARK: - Bind
  public func bind(reactor: BibleReadingPlanHomeReactor) {
    reactor.state
      .map { $0.currentReadChapters }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] currentReadChapters in
        guard let self else { return }
        let allChapters = reactor.totalChapters
        let percentage = Double(currentReadChapters)/Double(allChapters)*100.0
        let item = DailyBibleReadingChecklistCardItem(
          isExecutingState: currentReadChapters > 0,
          currentReadingPercentage: currentReadChapters > 0 ? percentage : 0.0)
        dailyReadingChallengeView.configure(with: item)
      }).disposed(by: disposeBag)
  }
  
  // MARK: - Actions
  @objc private func didTapDailyReadingChallengeView() {
    /// 이건 애니메이터한테 여기서 전해주자 : )
    if let window = view.window {
      var converted = dailyReadingChallengeView.convert(dailyReadingChallengeView.bounds, to: window)
      converted.size.width = converted.width - 32
      frameForStartingCustomTransitionComponent = converted
    } else {
      frameForStartingCustomTransitionComponent = dailyReadingChallengeView.frame
    }
    
    flowDependencies.showBibleReadingChecklistViewController(
      dismissCompletionHandler: { [weak self] in
        guard let self else { return }
        reactor?.action.onNext(.viewWillAppear)
      }, transitioningDelegator: self)
  }
}

// MARK: - UIViewControllerTransitioningDelegate
extension BibleReadingPlanHomeViewController: UIViewControllerTransitioningDelegate {
  /// 프레젠테이션 변환될 때 실행될 애니메이션
  public func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    return DailyReadingPlanExpendingAnimator(
      isPresenting: true,
      fromVC: self,
      frameForStartingCustomTransitionComponent: frameForStartingCustomTransitionComponent ?? .zero)
  }
  
  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return nil
  }
}
