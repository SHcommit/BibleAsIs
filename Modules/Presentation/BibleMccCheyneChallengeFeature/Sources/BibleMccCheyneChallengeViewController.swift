//
//  BibleMccCheyneChallengeViewController.swift
//  JourneyOfFaithMyActivityFeatureDemoApp
//
//  Created by 양승현 on 2/26/25.
//

import UIKit
import RxSwift
import RxRelay
import ReactorKit
import DesignSystem
import DesignSystemItems
import BibleMccCheyneChallengeInterface

/// 뷰 느낌으로 쓰자!
public final class BibleMccCheyneChallengeViewController: BaseViewController, View, BibleMccCheyneRefreshable {
  // MARK: - Constants
  public typealias Reactor = BibleMccCheyneChallengeReactor
  
  // MARK: - Properties
  public var disposeBag = DisposeBag()
  
  public var flowDependencies: BibleReadingPlanFlowDependencies
  
  public init(flowDependencies: BibleReadingPlanFlowDependencies) {
    self.flowDependencies = flowDependencies
    super.init(nibName: nil, bundle: nil)
  }
  
  private var isInitialRefreshDone = false
  
  @available(*, deprecated)
  required public init?(coder: NSCoder) { nil }
  
  private let challengeTitleAreaView = UILabel(frame: .zero).then {
    $0.setAutoLayout()
    $0.font = .jofHeadline
    $0.textColor = .palette(.title)
    $0.text = "맥체인 데일리 챌린지"
  }
  
  // MARK: - 맥체인이란? 없애기 맥체인 추가할까? 설명하는거?
//  private lazy var challengeTitleAreaView = IconTextTag(
//    iconSize: .init(width: 24, height: 24),
//    spacing: 7,
//    inset: .zero,
//    cornerRadius: 0,
//    textLabelFactory: {
//      $0.font = .jofHeadline
//      $0.textColor = .palette(.title)
//      $0.text = "맥체인 데일리 챌린지"
//    },
//    isIconFisrt: false,
//    wannaShowShadow: false
//  ).then {
//    $0.configure(icon: , text: "맥체인 데일리 챌린지", with: nil)
//  }
  
  private lazy var quotationView = QuotationWithVertiBarBibleVerseView(
    frame: .zero,
    shouldShowBorder: false,
    shouldShowShadow: false,
    shouldUseAppearAnimation: false,
    verseLabelFactory: { $0.font = .appleSDGothicNeo(.light, size: 14) },
    quotationVertiBarWidth: 2,
    wannaEqualToLayoutBookChapterVerseLabelBottomConstraint: true
  ).then {
    $0.setAutoLayout()
    $0.layer.cornerRadius = 0
    $0.layer.borderWidth = 0
  }
  
  private var challengeView: BibleChallengeView!
  
  private var lastOffsetX: CGFloat = 0
  
  private let velocityRelay = PublishRelay<CGFloat>()
  
  // MARK: - Lifecycle
  public override func viewDidLoad() {
    view.backgroundColor = .palette(.appearance)
    
    /// 여기서 이렇게하면 좋은점이 이전 scroll contentOffset 정할수있었음.
    /// 좀 아쉬운건 BibleChallengeView내부에서 이 클로저를 정의할 수 있지만, 그 내부에서는 self.init전에 클로저를 정의해서 layout 객체를 만들어야 한다.
    /// 이렇다는 것은 super.init()전에 자신의 변수를 캡쳐한다는 것이고 에러남 ㅇㅅㅇ..
    challengeView = BibleChallengeView(
      dataSourceProvider: reactor!,
      challengeDelegate: self
    ) { [weak self] _, offset, _ in
      guard let self else { return }
      
      let velocityX = offset.x - lastOffsetX
      lastOffsetX = offset.x
      velocityRelay.accept(abs(velocityX))
      
      let maxRotationAngle: CGFloat = 0.777 * .pi / 180
      let 최소속도: CGFloat = 0.27
      
      for _cell in challengeView.visibleCells {
        guard let indexPath = challengeView.indexPath(for: _cell), indexPath.section == 0 else { continue }
        
        let absVelocity = abs(velocityX)
        let isScrollingRight = velocityX > 0
        let isScrollingLeft = velocityX < 0
        
        let rotationValue: CGFloat
        if absVelocity > 5 {
          rotationValue = maxRotationAngle
        } else {
          rotationValue = (absVelocity * maxRotationAngle) / 7
        }
        
        let rotationAngle: CGFloat = isScrollingRight ? -rotationValue : (isScrollingLeft ? rotationValue : 0)
        
        if absVelocity < 최소속도 {
          /// 선택된거
          if indexPath.item == reactor!.selectedDayIndex {
            _cell.transform = CGAffineTransform.identity
          } else {
            _cell.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
          }
        } else {
          if indexPath.item == reactor!.selectedDayIndex {
            _cell.transform = CGAffineTransform(rotationAngle: rotationAngle)
          } else {
            _cell.transform = CGAffineTransform(
              rotationAngle: rotationAngle
            ).scaledBy(x: 0.8, y: 0.8)
          }
        }
      }
      challengeView.layoutIfNeeded()
    }
    /// 여기서 layoutUI호출되어야함 챌린지 뷰 초기화 후에
    super.viewDidLoad()
    bind()
    reactor?.action.onNext(.reload)
  }
  
  // MARK: - Layout
  public override func layoutUI() {
    [challengeTitleAreaView, quotationView, challengeView].forEach(view.addSubview)
    
    let challengeViewHeight: CGFloat = 290
    
    NSLayoutConstraint.activate([
      challengeTitleAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      challengeTitleAreaView.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
      
      /// 내부에 12만큼 inset 줬기 때문
      quotationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
      quotationView.topAnchor.constraint(equalTo: challengeTitleAreaView.bottomAnchor, constant: 14),
      quotationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      
      challengeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      challengeView.topAnchor.constraint(equalTo: quotationView.bottomAnchor, constant: 21),
      challengeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      challengeView.heightAnchor.constraint(equalToConstant: challengeViewHeight)
    ])
    
    challengeView.setProgressBar(from: view)
  }

  // MARK: - Helpers
  public func reloadData() {
    reactor?.action.onNext(.reload)
  }
  
  private func resetCellTransformsGradually() {
    UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .allowUserInteraction]) {
      for cell in self.challengeView.visibleCells {
        guard let indexPath = self.challengeView.indexPath(for: cell), indexPath.section == 0 else { continue }
        
        if indexPath.item == self.reactor!.selectedDayIndex {
          cell.transform = CGAffineTransform.identity
        } else {
          cell.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
        }
      }
    }
  }
  
  private func bind() {
    velocityRelay
      .debounce(.microseconds(77), scheduler: MainScheduler.instance)
      .filter {
        /// 이거 안해도 될거같구 최소 감속보다 큰경우 그니까 사용자가 스크롤 휙 쎄게 하고 바로 한번더 누른경우
        /// 가속도는 남아있는데, 사용자에의해정지됨 -> 이 경우 임 ㅇㅅㅇ...
        $0 > 0.5
      }.subscribe(onNext: { [weak self] _ in
        self?.resetCellTransformsGradually()
      }).disposed(by: disposeBag)
  }
  
  // MARK: - View
  public func bind(reactor: BibleMccCheyneChallengeReactor) {
    reactor.state
      .map { $0.refresh }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] wannaRefresh in
        guard let self else { return }
        guard wannaRefresh else { return }
        
        /// 이게 하 뷰디드 로드 좀 애매하네 요고 요고
        ///
        /// 가끔가다가 ```Warning once only: UITableView was told to layout its visible cells and other contents without being in the view hierarchy```
        /// 이거뜨잖어.
        ///
        /// 문제될건 없지만 그래도 뷰딛로드시점에서 reloadData같은 -> layoutIfNeeded이런게 호출될 수 있다는거지..
        self.challengeView.reloadData()
        if !isInitialRefreshDone {
          isInitialRefreshDone = true
        }

        challengeView.scrollToCurrentDay()
        
        quotationView.isHidden = false
        quotationView.configure(with: .init(book: .psalms, chapter: 119, verse: 105, content: "주의 말씀은 내 발에 등이요 내 길에 빛이니이다"))
        // 애니메이션 하지말자 quotation 애니메이션 안 할거임.
        // quotationView.animate(
        //   with: .init(book: .psalms,
        //               chapter: 119, verse: 105, content: "주의 말씀은 내 발에 등이요 내 길에 빛이니이다"))
        quotationView.alpha = 1
        
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.updatedCheckboxIndexPath }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] hasUpdatedIndexPath in
        guard let self else { return }
        if let hasUpdatedIndexPath {
          challengeView.updateCheckbox(challenge: hasUpdatedIndexPath)
        }
      }).disposed(by: disposeBag)
    
    /// 특정 체크박스 선택시
    reactor.state
      .map { $0.refreshChallenges }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] shouldRefresh in
        guard let self else { return }
        guard shouldRefresh else { return }
        guard isInitialRefreshDone else { return }
        /// 엥 아닌데?
        /// 매개변수로 newSelectedDay 이거받음
        challengeView.reloadSections(IndexSet(integer: 1))
      }).disposed(by: disposeBag)
    
    /// 모든 체크박스가 선택되어 특정 체크박스 선택시 - > 모든 체크 박스 선택된 경우
    reactor.state
      .map { $0.currentDayUpdated }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] currentDayUpdated in
        guard let self else { return }
        if let currentDayUpdated {
          challengeView.moveToNextChallengeDay(canMove: currentDayUpdated)
        }
      }).disposed(by: disposeBag)
  }
}

// MARK: - Actions
extension BibleMccCheyneChallengeViewController {
  @objc private func didTapMccCheyneDescription() {
    print("미 지원")
//    flowDependencies.showMccCheyneDescription()
  }
}
