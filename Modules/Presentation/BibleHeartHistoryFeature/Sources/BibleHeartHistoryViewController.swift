//
//  BibleHeartHistoryViewController.swift
//  MyActivityFeature
//
//  Created by 양승현 on 2/18/25.
//

import UIKit
import RxSwift
import ReactorKit
import DesignSystem
import DomainEntity
import DesignSystemInterface

public final class BibleHeartHistoryViewController: BaseViewController, View {
  public typealias Reactor = BibleHeartHistoryReactor
  
  public var disposeBag: RxSwift.DisposeBag = .init()
  
  // MARK: - Properties
  private let historyView: BibleVersesTimelineView = .init(forHeartUsage: true)
  
  private var forPageViewMode: Bool
  
  // MARK: - Lifecycle
  public init(forPageViewMode: Bool) {
    self.forPageViewMode = forPageViewMode
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, deprecated)
  required public init?(coder: NSCoder) { fatalError() }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    showGradientView()
    historyView.versesTimelineViewDelegate = self
    if !forPageViewMode {
      navigationItem.title = "하트 히스토리"
    }
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    reactor?.action.onNext(.refreshHistory)
  }
  
  // MARK: - Layout
  public override func layoutUI() {
    view.addSubview(historyView)
    
    NSLayoutConstraint.activate([
      historyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      historyView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
    if forPageViewMode {
      NSLayoutConstraint.activate([
        historyView.topAnchor.constraint(equalTo: view.topAnchor),
        historyView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      ])
    } else {
      NSLayoutConstraint.activate([
        historyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        historyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
      ])
    }
  }
  
  // MARK: - Helpers
  public func bind(reactor: BibleHeartHistoryReactor) {
    reactor.state
      .map { $0.shouldRefresh }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] shouldRefresh in
        guard let self else { return }
        guard shouldRefresh else { return }
        let sections = reactor.currentState.heartSections
        let items = reactor.currentState.heartItems
        historyView.configure(hasInitiallyFetched: reactor.currentState.hasInitiallyFetched, sections, items: items)
        historyView.reloadData()
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.shouldReloadSection }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] shouldReloadSpecificSection in
        guard shouldReloadSpecificSection else { return }
        guard let indexPath = reactor.currentState.updatedSectionIndexPath, let self
        else {
          assertionFailure("reactor에서 sectionIndex 넣어주길 바람!")
          ToastController.shared.showToast(
            message: "시스템 오류로 인해 해당 성경 구절 하트를 취소할 수 없습니다.\n 잠시 후에 다시 시도해주세요.",
            type: .error)
          return
        }
        let sections = reactor.currentState.heartSections
        let items = reactor.currentState.heartItems
        historyView.configure(hasInitiallyFetched: reactor.currentState.hasInitiallyFetched, sections, items: items)
        if sections.count == 0 {
          historyView.reloadData()
          return
        }
        
        /// 여기서 Delete Items -> reloadSection하면 안되는 이유 : 깜빡임 두번보임.
        /// Delete Items만 하면 안되는 이유 : section과 관련된 위 아래를 업데이트해야하는데, 특정한 셀만 지운다고
        /// 이 뷰가 원하는 로직으로 변하지 않음.
        self.historyView.reloadSections(IndexSet(integer: indexPath.section))
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.shouldDeleteSection }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] shouldDeleteSpecificSection in
        guard shouldDeleteSpecificSection else { return }
        guard let indexPath = reactor.currentState.updatedSectionIndexPath, let self
        else {
          assertionFailure("reactor에서 sectionIndex 넣어주길 바람!")
          ToastController.shared.showToast(
            message: "시스템 오류로 인해 해당 성경 구절 하트를 취소할 수 없습니다.\n 잠시 후에 다시 시도해주세요.",
            type: .error)
          return
        }
        let sections = reactor.currentState.heartSections
        let items = reactor.currentState.heartItems
        historyView.configure(hasInitiallyFetched: reactor.currentState.hasInitiallyFetched, sections, items: items)
        
        if sections.count == 0 {
          historyView.reloadData()
          return
        }
        
        historyView.performBatchUpdates {
          self.historyView.deleteSections(IndexSet(integer: indexPath.section))
        }
      }).disposed(by: disposeBag)
  }
}

// MARK: - BibleVerseTimelineViewDelegate
extension BibleHeartHistoryViewController: BibleVerseTimelineViewDelegate {
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) { }
  
  public func scrollViewDidScroll(with offsetY: CGFloat) { }
  
  public func didTapHeart(cell: UICollectionViewCell?, testament: DomainEntity.BibleTestament) {
    guard let cell, let indexPath = historyView.indexPath(for: cell)
    else { assertionFailure("self 참조 에러"); return }
    reactor?.action.onNext(.deselectHeart(testament: testament, IndexPath: indexPath))
  }
  
  public func didTapAllClear(for header: UICollectionReusableView) {
    guard let indexPath = historyView.indexPath(forSupplementaryView: header) else { return }
    reactor?.action.onNext(.removeAllHeart(for: indexPath))
  }
}
