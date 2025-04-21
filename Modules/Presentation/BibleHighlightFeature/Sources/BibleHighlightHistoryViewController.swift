//
//  BibleHighlightHistoryViewController.swift
//  MyActivityFeature
//
//  Created by 양승현 on 2/19/25.
//

import UIKit
import RxSwift
import ReactorKit
import DomainEntity
import DesignSystem
import BibleHighlightInterface

/// 페이징 적용안함
public final class BibleHighlightHistoryViewController: BaseViewController, View {
  public typealias Reactor = BibleHighlightHistoryReactor
  
  // MARK: - Properties
  public var disposeBag: RxSwift.DisposeBag = DisposeBag()

  private let tableView = UITableView.makeHighlightHistoryView(frame: .zero, style: .plain)
  
  private var adapter: BibleHighlightHistoryViewAdapter!
  
  private var flowDependencies: BibleHighlightFlowDependencies
  
  private var forPageView: Bool
  
  // MARK: - Lifecycle
  public init(forPageView: Bool, flowDependencies: BibleHighlightFlowDependencies) {
    self.forPageView = forPageView
    self.flowDependencies = flowDependencies
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, deprecated)
  required public init?(coder: NSCoder) { nil }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    adapter = BibleHighlightHistoryViewAdapter(dataSource: reactor, delegate: self, tableView: tableView)
    view.backgroundColor = .palette(.appearance)
    showGradientView()
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    reactor?.action.onNext(.itemsRefresh)
  }
  
  // MARK: - Layout
  public override func layoutUI() {
    [tableView].forEach(view.addSubview(_:))
    
    NSLayoutConstraint.activate([
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
    
    if forPageView {
      NSLayoutConstraint.activate([
        tableView.topAnchor.constraint(equalTo: view.topAnchor),
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      ])
    } else {
      NSLayoutConstraint.activate([
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
      ])
    }
  }

  // MARK: - Helpers
  public func bind(reactor: BibleHighlightHistoryReactor) {
    
    // 초기에 리엑터 첨 접할 때는 items에 따라서 reactor 바인딩을 했는데, 이게 잠재적으로
    // 처음엔 무저건 0개 -> 새롭게 데이터 받고 reload해야한느데, 그때도 데이터가 없으면 0개. 그러면 리엑터 바인딩 안먹힘 여전히 0이어서 (변화x)
    // 그래서 리프래시 목적인 바인딩은 다른거로 해야함
//    reactor.state
//      .map { $0.items }
//      .distinctUntilChanged()
//      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
//      .observe(on: MainScheduler.instance)
//      .subscribe(onNext: { [weak self] _ in
//        
//        if !reactor.hasInitiallyFetched { return }
//        self?.tableView.reloadData()
//      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.shouldRefresh }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] shouldRefresh in
        
        guard shouldRefresh else { return }
        if !reactor.hasInitiallyFetched { return }
        self?.tableView.reloadData()
      }).disposed(by: disposeBag)
  }
}

// MARK: - BibleHighlightHistoryAdapterDelegate
extension BibleHighlightHistoryViewController: BibleHighlightHistoryAdapterDelegate {
  func didTap(_ cell: UITableViewCell, indexPath: IndexPath) {
    guard let highlightItem = reactor?.currentState.items[indexPath.row] else {
      ToastController.shared.showToast(message: "하이라이트 한 성경 구절 식별자를 확보하지 못했습니다.\n잠시 후에 다시 시도해주세요", type: .error)
      return
    }
    
    let book = highlightItem.reference.book
    let testament = BibleTestament(isOldTestament: book.isOldTestament)
    let chapter = highlightItem.reference.chapter
    flowDependencies.showBibleReadingPage(
      testament: testament,
      book: book,
      chapter: chapter)
  }
}
