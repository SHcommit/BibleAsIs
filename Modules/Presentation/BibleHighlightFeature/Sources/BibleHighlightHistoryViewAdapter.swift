//
//  BibleHighlightHistoryViewAdapter.swift
//  MyActivityFeature
//
//  Created by 양승현 on 2/19/25.
//

import UIKit
import DesignSystem
import DesignSystemItems

protocol BibleHighlightHistoryAdapterDataSource: AnyObject {
  var hasInitiallyFetched: Bool { get }
  var numberOfItmes: Int { get }
  func item(_ row: Int) -> BiblehighlightHistoryItem
}

protocol BibleHighlightHistoryAdapterDelegate: AnyObject {
  func didTap(_ cell: UITableViewCell, indexPath: IndexPath)
}

final class BibleHighlightHistoryViewAdapter: NSObject {
  // MARK: - Properites
  private weak var dataSource: BibleHighlightHistoryAdapterDataSource!
  
  private weak var delegate: BibleHighlightHistoryAdapterDelegate!
  
  private var isEmpty: Bool {
    dataSource.numberOfItmes == 0
  }
  
  private var hasInitiallyEmptyViewAppeared = false
  
  // MARK: - Lifecycle
  init(
    dataSource: BibleHighlightHistoryAdapterDataSource?,
    delegate: BibleHighlightHistoryAdapterDelegate,
    tableView: UITableView
  ) {
    super.init()
    self.dataSource = dataSource
    self.delegate = delegate
    tableView.dataSource = self
    tableView.delegate = self
  }
}
// MARK: - UITableViewDataSource
extension BibleHighlightHistoryViewAdapter: UITableViewDataSource {
  public func numberOfSections(in tableView: UITableView) -> Int {
    if !dataSource.hasInitiallyFetched { return 0 }
    return 1
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if !dataSource.hasInitiallyFetched { return 0 }
    if isEmpty { return 1 }
    return dataSource.numberOfItmes
  }
  
  public func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    if !dataSource.hasInitiallyFetched { return .init() }
    guard indexPath.section == 0 else { return .init(frame: .zero) }
    if isEmpty {
      let cell = tableView.dequeueReusableCell(for: indexPath, type: HighlightsAreEmptyTableViewCell.self)
      return cell ?? .init(frame: .zero)
    }
    
    let item = dataSource.item(indexPath.row)
    if item.reference.book.isOldTestament {
      let oldTestamentCell = tableView.dequeueReusableCell(for: indexPath, type: OldBibleHighlightHistoryCell.self)
      oldTestamentCell?.configure(with: item)
      oldTestamentCell?.tap = { [weak self] cell in
        self?.delegate.didTap(cell, indexPath: indexPath)
      }
      return oldTestamentCell ?? .init(frame: .zero)
    } else {
      let newTestamentCell = tableView.dequeueReusableCell(for: indexPath, type: NewBibleHighlightHistoryCell.self)
      newTestamentCell?.configure(with: item)
      newTestamentCell?.tap = { [weak self] cell in
        self?.delegate.didTap(cell, indexPath: indexPath)
      }
      return newTestamentCell ?? .init(frame: .zero)
    }
  }
}

// MARK: - UITableViewDelegate
extension BibleHighlightHistoryViewAdapter: UITableViewDelegate {
  func tableView(
    _ tableView: UITableView,
    willDisplay cell: UITableViewCell,
    forRowAt indexPath: IndexPath
  ) {
    if isEmpty {
      if dataSource.hasInitiallyFetched, !hasInitiallyEmptyViewAppeared {
        hasInitiallyEmptyViewAppeared = true
        (cell as? HighlightsAreEmptyTableViewCell)?.showAnimation()
      }
      return
    }
    cell.fadeInFromBottom(duration: 0.21, initialOffsetY: 7)
    hasInitiallyEmptyViewAppeared = false
  }
}
