//
//  OnboardingViewController.swift
//  BibleAsIs
//
//  Created by 양승현 on 4/13/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import DesignSystem

final class OnboardingViewController: BaseViewController {
  // MARK: - Properties
  var shouldShowBibleFeedPage: (() -> Void)?
  
  private lazy var collectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .horizontal
    let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    cv.setAutoLayout()
    cv.dataSource = self
    cv.delegate = self
    cv.backgroundColor = .clear
    cv.register(OnboardingCell1.self)
    cv.register(OnboardingCell2.self)
    cv.register(OnboardingCell3.self)
    cv.register(OnboardingCell4.self)
    cv.register(OnboardingCell5.self)
    cv.isPagingEnabled = true
    cv.showsHorizontalScrollIndicator = false
    cv.isUserInteractionEnabled = false
    return cv
  }()
  
  private let pageControl = UIPageControl(frame: .zero).then {
    $0.setAutoLayout()
    $0.numberOfPages = 5
    $0.currentPage = 0
    $0.pageIndicatorTintColor = .palette(.border1)
    $0.currentPageIndicatorTintColor = .palette(.prograssBar2)
  }
  
  private let completionLabel = UILabel(frame: .zero).then {
    $0.setAutoLayout()
    $0.text = "다음"
    $0.font = .appleSDGothicNeo(.regular, size: 14)
    $0.textColor = .init(hexCode: "#FFFFFF")
    $0.textAlignment = .center
    $0.backgroundColor = .clear
  }
  
  private lazy var completionButton = GradientView(
    startColor: .palette(.readCompletedStartGradientColor1),
    endColor: .palette(.readCompletedEndGradientColor),
    startPoint: .init(x: 0.2, y: 0.2),
    endPoint: .init(x: 0.8, y: 1),
    locations: [0.05, 0.95]
  ).then {
    $0.setAutoLayout()
    $0.layer.cornerRadius = 20
    $0.layer.shadowColor = UIColor.init(hexCode: "#2D3E4E").cgColor
    $0.layer.shadowOffset = .init(width: 0, height: 2.5)
    $0.layer.shadowRadius = 20
    $0.isUserInteractionEnabled = true
    let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCompletionButton))
    $0.addGestureRecognizer(tap)
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.reloadData()
    collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
    view.backgroundColor = .palette(.appearance)
    pageControl.subviews.forEach {
      $0.transform = .init(scaleX: 0.7, y: 0.7)
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    completionButton.layer.shadowOpacity = 0.3
    completionButton.layer.shadowRadius = 12
  }
  
  override func layoutUI() {
    super.layoutUI()
    [collectionView, pageControl, completionButton, completionLabel].forEach(view.addSubview)
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//      collectionView.heightAnchor.constraint(equalToConstant: 624),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -107),
      
      pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 2),
      
      completionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      completionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      completionButton.heightAnchor.constraint(equalToConstant: 40),
      completionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -38),
      
      completionLabel.centerXAnchor.constraint(equalTo: completionButton.centerXAnchor),
      completionLabel.centerYAnchor.constraint(equalTo: completionButton.centerYAnchor)
    ])
  }
  
  private func updateCompletionLabel() {
    completionLabel.text = (pageControl.currentPage + 1 == pageControl.numberOfPages) ? "시작하기" : "다음"
  }
  
  @objc private func didTapCompletionButton() {
    if pageControl.currentPage + 1 < pageControl.numberOfPages {
      pageControl.currentPage += 1
      updateCompletionLabel()
      let indexPath = IndexPath(item: pageControl.currentPage, section: 0)
      collectionView.isPagingEnabled = false
      collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
      collectionView.isPagingEnabled = true

    } else {
      shouldShowBibleFeedPage?()
    }
  }
}

// MARK: - UICollectionViewDataSource
extension OnboardingViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    pageControl.numberOfPages
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    var cell: UICollectionViewCell?
    if indexPath.row == 0 {
      cell = collectionView.dequeueReusableCell(for: indexPath, type: OnboardingCell1.self)
    } else if indexPath.row == 1 {
      cell = collectionView.dequeueReusableCell(for: indexPath, type: OnboardingCell2.self)
    } else if indexPath.row == 2 {
      cell = collectionView.dequeueReusableCell(for: indexPath, type: OnboardingCell3.self)
    } else if indexPath.row == 3 {
      cell = collectionView.dequeueReusableCell(for: indexPath, type: OnboardingCell4.self)
    } else if indexPath.row == 4 {
      cell = collectionView.dequeueReusableCell(for: indexPath, type: OnboardingCell5.self)
    }
    cell?.isUserInteractionEnabled = false
    return cell ?? .init(frame: .zero)
  }
}

// MARK: - UICollectionViewDelegate
extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
  }
  
//  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//    let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
//    
//    if page != pageControl.currentPage {
//      pageControl.currentPage = page
//      updateCompletionLabel()
//    }
//  }
//  
  // 스크롤 해서 옆으로 이동 하지말자 ui상 별로임
//  func scrollViewWillEndDragging(
//    _ scrollView: UIScrollView,
//    withVelocity velocity: CGPoint,
//    targetContentOffset: UnsafeMutablePointer<CGPoint>
//  ) {
//    let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
//    
//    if currentPage == 0 && velocity.x < 0 {
//      targetContentOffset.pointee = CGPoint(x: 0, y: 0)
//    }
//    
//    if currentPage == pageControl.numberOfPages - 1 && velocity.x > 0 {
//      targetContentOffset.pointee = CGPoint(x: scrollView.contentOffset.x, y: 0)
//    }
//  }
}
