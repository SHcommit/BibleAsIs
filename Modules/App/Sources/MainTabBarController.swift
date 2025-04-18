//
//  MainTabBarController.swift
//  JourneyOfFaithApp
//
//  Created by 양승현 on 4/1/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import DesignSystem

public final class MainTabBarController: UITabBarController {
  // MARK: - Properties
  private let flowDependencies: MainTapFlowDependencies
  
//  private let blurView = BlurWithVibrancyView(blurStyle: .systemThickMaterial, vibrancyStyle: .fill).setAutoLayout()
  
  // MARK: - Lifecycle
  public init(flowDependencies: MainTapFlowDependencies) {
    self.flowDependencies = flowDependencies
    super.init(nibName: nil, bundle: nil)
    configureUI()
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) { nil }
  
  public override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    layoutUI()
  }
  
  // MARK: - LayoutUI
  func layoutUI() {
//    tabBar.insertSubview(blurView, at: 0)
//    NSLayoutConstraint.activate([
//      blurView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
//      blurView.topAnchor.constraint(equalTo: tabBar.topAnchor),
//      blurView.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
//      blurView.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor)
//    ])
  }
  
  // MARK: - Helpers
  func configureUI() {
    let appearance = UITabBarAppearance()
    appearance.configureWithDefaultBackground()
    appearance.backgroundColor = .palette(.appearance)
    tabBar.standardAppearance = appearance
    if #available(iOS 15.0, *) {
      tabBar.scrollEdgeAppearance = appearance
    }
    
    tabBar.isTranslucent = false
    tabBar.tintColor = .palette(.icon)
    
    let homeTabBarItem = makeTabBarItem(
      title: "홈",
      selectedAsset: .selectedHome,
      deselectedAsset: .deselectedHome)
    let bibleHomeTabBarItem = makeTabBarItem(
      title: "바이블",
      selectedAsset: .selectedReadingBible,
      deselectedAsset: .deselectedReadingBible)
    let myActivityTabBarItem = makeTabBarItem(
      title: "내 활동",
      selectedAsset: .selectedMyBible,
      deselectedAsset: .deselectedMyBible)
    
    let homeViewController = flowDependencies.makeHomeViewController(with: homeTabBarItem)
    let bibleHomeViewController = flowDependencies.makeBibleHomeViewController(with: bibleHomeTabBarItem)
    let myActivityViewController = flowDependencies.makeMyActivityViewController(with: myActivityTabBarItem)
    
    viewControllers = [homeViewController, bibleHomeViewController, myActivityViewController]
  }
  
  private func makeTabBarItem(title: String, selectedAsset: IconAsset, deselectedAsset: IconAsset) -> UITabBarItem {
    return UITabBarItem(title: title, image: UIImage.asset(deselectedAsset), selectedImage: .asset(selectedAsset))
  }
}
