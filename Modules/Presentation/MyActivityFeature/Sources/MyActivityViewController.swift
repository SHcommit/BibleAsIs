//
//  MyActivityViewController2.swift
//  MyActivityFeature
//
//  Created by 양승현 on 2/17/25.
//

import UIKit
import DesignSystem
import DesignSystemItems
import MyActivityInterface

/// isDouble하고 그 pageCruel했는데 별로 안 이쁨...
/// 그리고 menu영역은 이제 그 현재 보여지는 화면의 상위에 클립 메뉴? 를 추가로 달아서 page cruel될때 같이 이동해서 생동감 주려했는데 pagecurel을 사용자가 직접안하고
/// 시스템에 의해서 nextPage로 하면 좌 우 curel animation만 됨.
public final class MyActivityViewController: BaseViewController {
  private let menuItems: [(name: String, width: CGFloat)] = [("묵상 챌린지", 109), ("형광펜", 82), ("하트", 70), ("노트", 70)]
  
  // MARK: - Properties
  private lazy var menuStackView = UIStackView(arrangedSubviews: makeMenuStackView()).then {
    $0.setAutoLayout()
    $0.axis = .horizontal
    $0.spacing = 2
    $0.distribution = .equalSpacing
    $0.alignment = .leading
  }
  
  private let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal).then {
    $0.view.translatesAutoresizingMaskIntoConstraints = false
  }
  
  private var pageView: UIView! {
    pageController.view
  }
  
  private var safeAreaBackgroundView = UIView(frame: .zero).then {
    $0.setAutoLayout()
    $0.backgroundColor = .palette(.title)
  }
  
  private var selectedMenuIndex = 0
  
  private var flowDependencies: MyActivityCoordinatorFlowDependencies
  
  // MARK: - Lifecycle
  public init(flowDependencies: MyActivityCoordinatorFlowDependencies) {
    self.flowDependencies = flowDependencies
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, deprecated)
  required public init?(coder: NSCoder) { fatalError() }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .palette(.appearance)
    selectMenu(isNextPage: true, withAnim: false)
    updateAppearance()
    let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    view.addGestureRecognizer(swipeGesture)
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  public override func updateAppearance() {
    super.updateAppearance()
    safeAreaBackgroundView.backgroundColor = .init(hexCode: isDarkMode ? "#323232" : "#222831")
    menuStackView.arrangedSubviews.enumerated().forEach { i, e in
      if i == selectedMenuIndex {
        e.backgroundColor = .palette(.appearance)
        (e as? PaddingLabel)?.textColor = .palette(.title)
      } else {
        e.backgroundColor = UIColor(hexCode: deselectedMenuColorHex)
        (e as? PaddingLabel)?.textColor = .palette(.deselectedMenuText)
      }
    }
  }
  
  // MARK: - Layout
  public override func layoutUI() {
    [safeAreaBackgroundView, pageView, menuStackView].forEach(view.addSubview(_:))
    layoutReversedGradientView { [weak self] in
      guard let self else { return [] }
      return [
        $0.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        $0.topAnchor.constraint(equalTo: pageView.topAnchor),
        $0.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        $0.heightAnchor.constraint(equalToConstant: 16)]
    }
    
    NSLayoutConstraint.activate([
      safeAreaBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      safeAreaBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
      safeAreaBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      safeAreaBackgroundView.bottomAnchor.constraint(equalTo: pageView.topAnchor),
      
      menuStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      menuStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
      
      pageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      pageView.topAnchor.constraint(equalTo: menuStackView.bottomAnchor),
      pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      pageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
  }

  // MARK: - Helpers
  public func selectMenu(
    isNextPage: Bool,
    withAnim: Bool
  ) {
    let direction: UIPageViewController.NavigationDirection = isNextPage ? .forward : .reverse
    
    var newVC: [UIViewController] = []
    if selectedMenuIndex == 0 {
      newVC = [makeBibleReadingPlanHomeViewController()]
    } else if selectedMenuIndex == 1 {
      newVC = [makeHighlightHistoryViewController()]
    } else if selectedMenuIndex == 2 {
      newVC = [makeHeartHistoryViewController()]
    } else {
      newVC = [makeBibleNoteHomeViewController()]
    }
    
    pageController.setViewControllers(newVC, direction: direction, animated: withAnim)
  }
  
  public func currentPageVC() -> UIViewController? {
    pageController.viewControllers?.first
  }
  
  private func makeMenuStackView() -> [UIView] {
    return menuItems.map { item in
      let menuView = PaddingLabel(padding: .init(top: 5, left: 14, bottom: 5, right: 0))
      menuView.text = item.name
      menuView.setRadius(12, withSpecificPositions: [.leftTop, .rightTop])
      menuView.clipsToBounds = true
      menuView.font = .appleSDGothicNeo(.regular, size: 14)
      menuView.textColor = .palette(.title)
      menuView.widthAnchor.constraint(equalToConstant: item.width).isActive = true
      menuView.isUserInteractionEnabled = true
      let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapMenu))
      menuView.addGestureRecognizer(tapGesture)
      menuView.heightAnchor.constraint(equalToConstant: 32).isActive = true
      return menuView
    }
  }
  
  // MARK: - Actions
  /// 주의할게 UIView로하면 업 캐스팅된 UIView 타입이 담기니깐 이거 주소비교할때 firstIndex(of:) 인식 못함. PaddingLabel로 캐스팅해야함
  @objc private func tapMenu(_ gesture: UIGestureRecognizer) {
    guard let menuView = gesture.view else {
      ToastController.shared.showToast(
        message: "서비스 오류로 다른 메뉴로 이동할 수 없습니다.\n잠시 후에 다시 시도해주세요",
        type: .error)
      return
    }
    guard let index = menuStackView.arrangedSubviews.firstIndex(of: menuView) else { return }
    if index == selectedMenuIndex { return }
    view.isUserInteractionEnabled = false
    let prevIndex = selectedMenuIndex
    let isNextPage = selectedMenuIndex < index
    selectedMenuIndex = index
    showOtherMenu(prevMenuIndex: prevIndex, upcomingMenuIndex: selectedMenuIndex, isNextPage: isNextPage)
  }
  
  private func showOtherMenu(prevMenuIndex: Int, upcomingMenuIndex: Int, isNextPage: Bool) {
    selectMenu(isNextPage: isNextPage, withAnim: true)
    let prevMenu = menuStackView.arrangedSubviews[prevMenuIndex] as? PaddingLabel
    let selectedMenu = menuStackView.arrangedSubviews[selectedMenuIndex] as? PaddingLabel
    prevMenu?.backgroundColor = UIColor(hexCode: deselectedMenuColorHex)
    prevMenu?.textColor = .palette(.deselectedMenuText)
    
    /// 너무 빨리 사용자가 왔다갔다 탭 누르면 이거 에러날수있음 ㅇㅅㅇ
    menuStackView.isUserInteractionEnabled = false
    menuStackView.arrangedSubviews[selectedMenuIndex].touchDepth(duration: 0.17, y: 2.3, completion: { [weak self] _ in
      /// 너무 빨리 화면 이동하는거 방지
      DispatchQueue.main.asyncAfter(deadline: .now()+0.07, execute: {
        self?.menuStackView.isUserInteractionEnabled = true
        self?.view.isUserInteractionEnabled = true
      })
    })
    selectedMenu?.animateCornerRadius(to: 7)
    prevMenu?.animateCornerRadius(to: 12)
    selectedMenu?.backgroundColor = .palette(.appearance)
    selectedMenu?.textColor = .palette(.title)
  }
  
  // MARK: - Factory
  private func makeHeartHistoryViewController() -> UIViewController {
    flowDependencies.makeHeartHistoryViewController()
  }
  
  private func makeHighlightHistoryViewController() -> UIViewController {
    return flowDependencies.makeBibleHighlightHistoryViewController()
  }
  
  private func makeBibleReadingPlanHomeViewController() -> UIViewController {
    return flowDependencies.makeBibleReadingPlanHomeViewController()
  }
  
  @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
    let velocity = gesture.velocity(in: view)
    
    guard gesture.state == .ended else { return }
    
    if velocity.x > 500 {
      view.isUserInteractionEnabled = false
      if selectedMenuIndex == 0 { return }
      let prevMenu = selectedMenuIndex
      selectedMenuIndex -= 1
      showOtherMenu(prevMenuIndex: prevMenu, upcomingMenuIndex: selectedMenuIndex, isNextPage: false)
    } else if velocity.x < -500 {
      view.isUserInteractionEnabled = false
      if selectedMenuIndex == menuItems.count - 1 { return }
      let prevMenu = selectedMenuIndex
      selectedMenuIndex += 1
      showOtherMenu(prevMenuIndex: prevMenu, upcomingMenuIndex: selectedMenuIndex, isNextPage: true)
    }
  }
  
  private func makeBibleNoteHomeViewController() -> UIViewController {
    flowDependencies.makeBibleNoteHomeViewController()
  }
}
