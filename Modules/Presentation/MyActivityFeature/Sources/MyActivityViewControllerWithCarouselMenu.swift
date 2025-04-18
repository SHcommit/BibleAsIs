//
//  MyActivityViewController.swift
//  MyActivityFeature
//
//  Created by 양승현 on 2/17/25.
//

import UIKit
import DesignSystem
import DesignSystemItems
import MyActivityInterface

@available(*, deprecated, renamed: "MyActivityViewController", message: "디자인 너무 일반적인거같아")
public final class __MyActivityViewController: BaseViewController {
  // MARK: - Properties
  private lazy var menuStackView = UIStackView(arrangedSubviews: makeMenuStackView()).then {
    $0.setAutoLayout()
    $0.axis = .horizontal
    $0.distribution = .equalSpacing
    $0.alignment = .center
  }
  
  private let grayLine = UIView(frame: .zero).then {
    $0.setAutoLayout()
    $0.backgroundColor = .palette(.border2)
  }
  
  private var menuViews: [MenuViewWithMovableVertiBar] {
    menuStackView.arrangedSubviews.compactMap { $0 as? MenuViewWithMovableVertiBar }
  }
  
  private let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal).then {
    $0.view.translatesAutoresizingMaskIntoConstraints = false
  }
  
  private var pageView: UIView! {
    pageController.view
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
    menuViews[selectedMenuIndex].selectMenu()
    showCurrentViewController(isNextPage: true, withAnim: false)
  }
  
  // MARK: - Layout
  public override func layoutUI() {
    [pageView, grayLine, menuStackView].forEach(view.addSubview(_:))
    NSLayoutConstraint.activate([
      menuStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
      menuStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
      menuStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
      
      grayLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      grayLine.topAnchor.constraint(equalTo: menuStackView.bottomAnchor),
      grayLine.heightAnchor.constraint(equalToConstant: 1),
      grayLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      
      pageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      pageView.topAnchor.constraint(equalTo: menuStackView.bottomAnchor),
      pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      pageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
  }

  // MARK: - Helpers
  public func currentPageVC() -> UIViewController? {
    pageController.viewControllers?.first
  }
  
  private func makeMenuStackView() -> [UIView] {
    let items = ["하트 일지", "형광펜", "성경 읽기 플랜", "노트"]
    return items.map {
      let menuView = MenuViewWithMovableVertiBar(frame: .zero)
      menuView.configure(with: $0)
      menuView.tap = tapMenu(_:)
      menuView.heightAnchor.constraint(equalToConstant: 34).isActive = true
      return menuView
    }
  }
  
  // MARK: - Actions
  func tapMenu(_ menuView: UIView) {
    guard let index = menuStackView.arrangedSubviews.firstIndex(of: menuView) else { return }
    if index == selectedMenuIndex { return }
    menuViews[selectedMenuIndex].deselectMenu()
    menuViews[index].selectMenu()
    menuViews[index].touchDepth(y: 0.777)
    let isNextPage = selectedMenuIndex < index
    selectedMenuIndex = index
    
    showCurrentViewController(isNextPage: isNextPage, withAnim: true)
  }
  
  // MARK: - Helpers
  private func showCurrentViewController(isNextPage: Bool, withAnim: Bool) {
    let direction: UIPageViewController.NavigationDirection = isNextPage ? .forward : .reverse
    let newVC: UIViewController = [
      0: makeHeartHistoryViewController(),
      1: makeHighlightHistoryViewController(),
      2: makeBibleReadingPlanHomeViewController(),
      3: makeBibleNoteHomeViewController()
    ] [selectedMenuIndex]!
    
    pageController.setViewControllers([newVC], direction: direction, animated: withAnim)
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
  
  private func makeBibleNoteHomeViewController() -> UIViewController {
    flowDependencies.makeBibleNoteHomeViewController()
  }
}
