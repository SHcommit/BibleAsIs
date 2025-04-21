//
//  BiblePaginationViewController.swift
//  BibleContentFeature
//
//  Created by 양승현 on 2/16/25.
//

import UIKit
import Common
import DesignSystem
import RxSwift
import ReactorKit
import DomainEntity
import DesignSystemItems
import DesignSystemInterface
import BibleReadingInterface

public final class BibleReadingContainerViewController: BaseViewController {
  // MARK: - Properties
  private var titleViewDisplayAnimator: UIViewPropertyAnimator?
  
  private let navigationTitleViewArea = UIView(frame: .zero)
  
  private let navigationTitleLabel = UILabel(frame: .zero).then {
    $0.setAutoLayout()
    $0.textAlignment = .center
    $0.numberOfLines = 1
    $0.font = .appleSDGothicNeo(.bold, size: 17)
    $0.textColor = .palette(.title)
  }
    
  private var readingPageCoordinator: BibleReadingPageCoordinator!
  
  public var disposeBag: RxSwift.DisposeBag = .init()
  
  private let paginationController: BiblePaginationDataSource
  
  private var flowDependencies: BibleReadingFlowDependencies?
  
  /// 앱 실행하고 첨에만 에딧메뉴 호출해주는거 너무 느려...
  /// 미리 한번 로드해보자.
  private var hasPreloadEditMenu = false
  
  // MARK: - Lifecycle
  public init(paginationController: BiblePaginationDataSource, flowDependencies: BibleReadingFlowDependencies?) {
    self.paginationController = paginationController
    self.flowDependencies = flowDependencies
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .palette(.appearance)
    readingPageCoordinator = BibleReadingPageCoordinator(
      bibleDataSource: paginationController,
      bibleReadingPageFactory: self)
    readingPageCoordinator.addChild(self)
    readingPageCoordinator.layout(in: view)
    readingPageCoordinator.configureUI()
    layoutNavigationTitle()
    setMenuBarItem()
    showGradientView()
    if !hasPreloadEditMenu {
      hasPreloadEditMenu = true
      preloadEditMenu()
    }
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if navigationController?.isNavigationBarHidden == true {
      navigationController?.setNavigationBarHidden(false, animated: false)
    }
  }
  
  public override func updateAppearance() {
    super.updateAppearance()
    setMenuBarItem()
    let backBarItem = makeBackItem()
    navigationItem.setLeftBarButton(backBarItem, animated: true)
  }
  
  // MARK: - Helpers
  
  private func layoutNavigationTitle() {
    navigationTitleViewArea.addSubview(navigationTitleLabel)
    NSLayoutConstraint.activate([
      navigationTitleLabel.leadingAnchor.constraint(equalTo: navigationTitleViewArea.leadingAnchor),
      navigationTitleLabel.topAnchor.constraint(equalTo: navigationTitleViewArea.topAnchor),
      navigationTitleLabel.trailingAnchor.constraint(equalTo: navigationTitleViewArea.trailingAnchor),
      navigationTitleLabel.bottomAnchor.constraint(equalTo: navigationTitleViewArea.bottomAnchor)
    ])
    navigationItem.titleView = navigationTitleViewArea
  }
  
  private func configureNavigationTitle(title: String) {
    navigationTitleLabel.text = title
    navigationTitleLabel.alpha = 0
    navigationTitleLabel.transform = .init(translationX: 0, y: navigationTitleLabel.font.lineHeight-7)
    navigationTitleLabel.isHidden = true
  }
  
  private var updatedFontModifier: ((CGFloat) -> Void)?
  
  private var ownerPickSleepTimeOptionHandler: ((SleepTimerOption) -> Void)?
  
  private func setMenuBarItem() {
    let menuItem = UIBarButtonItem.makeMenu2Item(self, action: #selector(didTapMenu2BarItem))
    navigationItem.setRightBarButton(menuItem, animated: true)
  }
  
  private func preloadEditMenu() {
    if #available(iOS 16.0, *) {
      let dummyTextView = UITextView(frame: CGRect(x: -30, y: -200, width: 1, height: 1))
      dummyTextView.text = "dummy"
      dummyTextView.isSelectable = true
      dummyTextView.isEditable = false
      dummyTextView.alpha = 0.0
      view.addSubview(dummyTextView)
      
      let range = dummyTextView.textRange(
        from: dummyTextView.beginningOfDocument,
        to: dummyTextView.beginningOfDocument)!
      dummyTextView.selectedTextRange = range
      
      let interaction = UIEditMenuInteraction(delegate: nil)
      dummyTextView.addInteraction(interaction)
      
      let config = UIEditMenuConfiguration(identifier: "warmup", sourcePoint: CGPoint(x: 1, y: 1))
      
      UIView.performWithoutAnimation {
        interaction.presentEditMenu(with: config)
        interaction.dismissMenu()
      }
      
      dummyTextView.removeFromSuperview()
    } else {
      let dummyTextView = UITextView(frame: CGRect(x: -30, y: -200, width: 1, height: 1))
      dummyTextView.text = "dummy"
      dummyTextView.isEditable = false
      dummyTextView.isSelectable = true
      dummyTextView.alpha = 0
      view.addSubview(dummyTextView)
      
      let range = dummyTextView.textRange(
        from: dummyTextView.beginningOfDocument,
        to: dummyTextView.beginningOfDocument)!
      dummyTextView.selectedTextRange = range
      let rect = dummyTextView.firstRect(for: range)
      
      let menu = UIMenuController.shared
      menu.menuItems = []
      UIView.performWithoutAnimation {
        menu.showMenu(from: dummyTextView, rect: rect)
        menu.hideMenu(from: dummyTextView)
      }
      
      dummyTextView.removeFromSuperview()
    }
  }

  // MARK: - Actions
  @objc private func didTapMenu2BarItem() {
    flowDependencies?.showSettingViewController(
      updatedFontSizeHandler: updatedFontModifier,
      ownerPickSleepTimeOptionHandler: ownerPickSleepTimeOptionHandler)
  }
}

extension BibleReadingContainerViewController: BibleReadingPageFactory {
  /// 얘는 만들어내야 함
  /// 성경 컨텐츠 페이지를 전환하는 경우는 크게 3가지가 있음.
  /// 1. 바이블 books index 페이지(books accordion)에 의한 자유로운 chapter이동이 가능한 페이지 ( isRestrictEntry == false )
  /// 2. 여러 미션에서 특정한 미션을 수행하기 위해 진입하는 경우. 이 경우 화면 이동을 제약해야함 ( isRestrictEntry == true )
  /// 3. 오디오에 의한 진입. 사용자가 오디오를 수행하면 그것에 의해 진입됨 ( entryBySleepAudioPlay == true )
  public func makeBibleReadingPage(
    currentReadingEntryItem: BibleReadingEntryItem,
    bibleReadingEntryItemsForRange: [BibleReadingEntryItem],
    entryBySleepAudioPlay: Bool
  ) -> UIViewController {
    
    configureNavigationTitle(title: "")
    guard let bibleReadingViewController = flowDependencies?.makeBibleReadingPage(
      currentReadingEntryItem: currentReadingEntryItem,
      bibleReadingEntryItemsForRange: bibleReadingEntryItemsForRange,
      entryBySleepAudioPlay: entryBySleepAudioPlay,
      delegate: self
    ) as? BibleReadingViewController else {
      fatalError(String.registrationErrorMsgByInner(BibleReadingViewController.self))
    }
   
    updatedFontModifier = bibleReadingViewController.handleUpdatedFont(_:)
    ownerPickSleepTimeOptionHandler = bibleReadingViewController.handleOwnerPickSleepTimeOption(_:)
    
    return bibleReadingViewController
  }
}

// MARK: - BibleReadingViewControllerDelegate
extension BibleReadingContainerViewController: BibleReadingViewControllerDelegate {
  /// 여기서 이전화면을 보여주는데,
  ///
  /// 경우가 두 가지임
  /// 1. 사용자가 바이블 컨텐츠 ControlView 화살표 버튼에 의해 화면 이동을 하는 경우
  /// 2. 오디오에 의한 화면 전환의 경우.
  ///   이 경우는 매개변수에 값이 주어짐
  public func handlePrevPageShowing(_ bySleepTimer: Bool) {
    readingPageCoordinator.showPrevPage(bySleepTimer: bySleepTimer)
  }
  
  public func handleNextPageShowing(_ bySleepTimer: Bool) {
    readingPageCoordinator.showNextPage(bySleepTimer: bySleepTimer)
  }
  
  public func provideNavigationTitle(_ title: String) {
    if navigationTitleLabel.text == "" {
      navigationTitleLabel.text = title
    }
  }
  
  public func willDisplayTitleHeaderView(_ title: String?) {
    if navigationTitleLabel.text == "" {
      navigationTitleLabel.text = title
    }
    let fontHeight = navigationTitleLabel.font.lineHeight
    titleViewDisplayAnimator?.stopAnimation(true)
    titleViewDisplayAnimator = UIViewPropertyAnimator(
      duration: 0.28,
      curve: .easeIn,
      animations: { [weak self] in
        guard let self else { return }
        navigationTitleLabel.alpha = 0
        navigationTitleLabel.transform = .init(translationX: 0, y: fontHeight-7)
      })
    titleViewDisplayAnimator?.addCompletion { [weak self] _ in
      self?.navigationTitleLabel.isHidden = true
    }
    titleViewDisplayAnimator?.startAnimation()
  }
  
  public func disappearTitleHeaderView() {
    navigationTitleLabel.isHidden = false
    titleViewDisplayAnimator?.stopAnimation(true)
    titleViewDisplayAnimator = UIViewPropertyAnimator(
      duration: 0.28,
      curve: .easeOut,
      animations: { [weak self] in
        guard let self else { return }
        navigationTitleLabel.transform = .identity
        navigationTitleLabel.alpha = 1
      }
    )
    titleViewDisplayAnimator?.startAnimation()
  }
  
  public func hideNavigationMenuItem() {
    navigationItem.setRightBarButton(nil, animated: true)
  }
  
  public func showNavigationMenuItem() {
    setMenuBarItem()
  }
}
