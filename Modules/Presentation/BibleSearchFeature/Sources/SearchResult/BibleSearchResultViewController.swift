//
//  BibleSearchResultViewController.swift
//  BibleSearchFeature
//
//  Created by 양승현 on 2/25/25.
//

import UIKit
import RxSwift
import ReactorKit
import DesignSystem
import DesignSystemItems
import DesignSystemInterface

public final class BibleSearchResultViewController: BaseViewController, View {
  public typealias Reactor = BibleSearchResultReactor
  
  public var disposeBag: DisposeBag = .init()
  
  // MARK: - Properties
  private let resultView = UITableView.makeBibleSearchResultView(frame: .zero).setAutoLayout()
  
  private var resultViewAdapter: BibleSearchResultViewAdapter!
  
  public var wannaDisappearKeyboard: (() -> Void)?
  
  /// 화면 이동
  public var showBibleReadingPage: ((BibleVerseItem) -> Void)?
  
  /// 바이블 읽는거 진행됨을 알려줌.
  /// 검색 히스토리 업데이트 해야한다면, 이걸 통해서 하자.
  public var didTapForReadingBibleReadingPage: (() -> Void)?
  
  // MARK: - Lifecycle
  public override func viewDidLoad() {
    super.viewDidLoad()
    resultViewAdapter = BibleSearchResultViewAdapter(
      dataSource: reactor,
      delegate: self,
      tableView: resultView)
    layoutGradientView(from: resultView)
  }
  
  /// 아후.. 간혹가다가 이게 서치컨트롤러 이전 뷰컨에서꺼랑 겹쳐서 취소버튼이 0.0 기준으로 살짝 보일 수 있음 조심해야함
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    resignFirstResponder()
  }
  
  // MARK: - Layout
  public override func layoutUI() {
    view.addSubview(resultView)
    NSLayoutConstraint.activate([
      resultView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      resultView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      resultView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      resultView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
  }

  // MARK: - Bind
  public func bind(reactor: BibleSearchResultReactor) {
    reactor.state.map { $0.reloadForNewPage }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] wannaRefresh in
        if wannaRefresh {
          self?.resultView.reloadData()
        }
      }).disposed(by: disposeBag)
    
    reactor.state.map { $0.isSearchResultEmpty }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] isSearchResultEmpty in
        if isSearchResultEmpty {
          self?.resultView.reloadData()
        }
      }).disposed(by: disposeBag)
    
    reactor.state.map { $0.isLoading }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] loading in
        guard let self else { return }
        
        if reactor.numberOfItems == 0 { return }
        if loading { return }
        if resultView.tableFooterView == nil { return }
        resultView.tableFooterView = nil
        
        let startIndex = reactor.currentState.numberOfPrevItems
        let endIndex = reactor.currentState.items.count
        
        guard startIndex < endIndex else { return }
        let indexPaths = (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
        UIView.performWithoutAnimation {
          self.resultView.performBatchUpdates {
            self.resultView.insertRows(at: indexPaths, with: .none)
          }
        }
        
      }).disposed(by: disposeBag)
  }
  
  public func update(textDidChange searchText: String) {
    reactor?.action.onNext(.queryFetch(searchText))
  }
}

// MARK: - BibleSearchResultViewAdapterDelegate
extension BibleSearchResultViewController: BibleSearchResultViewAdapterDelegate {
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    wannaDisappearKeyboard?()
  }
  
  public func showBibleContent(with cell: UITableViewCell) {
    guard let indexPath = resultView.indexPath(for: cell) else { return }
    reactor?.action.onNext(.SearchedUserQuerySaveInDiskMemory(indexPath: indexPath))
    guard let bibleVerseItem = reactor?.currentState.items[indexPath.row] else {
      ToastController.shared.showToast(message: "죄송합니다 검색 결과 데이터를 식별할 수 없습니다. 다시 시도해주세요.", type: .error)
      return
    }
    showBibleReadingPage?(bibleVerseItem)
    /// 혹시 좀 메인에서 너무 다 처리할까봐
    DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 0.3, execute: {
      DispatchQueue.main.async {
        self.didTapForReadingBibleReadingPage?()
      }
    })
  }
  
  public func showNextPage() {
    resultView.tableFooterView = LoadingTableViewFooterView(
      frame: .init(origin: .zero,
                   size: .init(width: 0, height: LoadingTableViewFooterView.Height)))
    reactor?.action.onNext(.nextPage)
  }
}
