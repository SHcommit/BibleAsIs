//
//  FeedSettingViewController.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 4/10/25.
//

import UIKit
import Common
import RxSwift
import ReactorKit
import DomainEntity
import DesignSystem

final class FeedSettingViewController: UITableViewController, View, Identifiable {
  typealias Reactor = FeedSettingReactor
  
  var disposeBag: DisposeBag = .init()
  
  private(set) var userItems = ["디스플레이 설정"]
  
  private(set) var etcItems = ["문의하기", "오픈 소스", "Credits"]
//  private(set) var etcItems = ["이용약관", "문의하기", "Credits"]
  
  private(set) var flowDependencies: FeedSettingFlowDependencies
  
  private var hasDisplaySegmentControlSetupDone = false
  
  init(flowDependencies: FeedSettingFlowDependencies) {
    self.flowDependencies = flowDependencies
    super.init(style: .grouped)
    hidesBottomBarWhenPushed = true
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) { nil }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "설정"
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.separatorStyle = .none
    tableView.rowHeight = 52
    tableView.backgroundColor = .palette(.appearance)
    tableView.delaysContentTouches = false
    tableView.contentInset = .init(top: 20, left: 0, bottom: 0, right: 0)
    tableView.backgroundColor = .palette(.appearance)
    tableView.scrollIndicatorInsets = .init(top: 0, left: 0.7, bottom: 0, right: 0)
    if #available(iOS 15.0, *) {
      tableView.sectionHeaderTopPadding = 0
    }
    tableView.register(FeedSettingDisplayCell.self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    reactor?.action.onNext(.viewDidLoad)
    navigationController?.interactivePopGestureRecognizer?.isEnabled = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
  }
  
  // MARK: - Bind
  func bind(reactor: FeedSettingReactor) {
    reactor.state
      .map { $0.viewDidLoadCompletion }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] hasDone in
        guard let self else { return }
        guard hasDone else { return }
        tableView.reloadData()
        UIApplication.updateAppearance(reactor.currentState.appearance)
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.displayAppearanceUpdateCompletion }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] hasDisplayAppearanceUpdatedDone in
        guard let self else { return }
        guard hasDisplayAppearanceUpdatedDone else { return }
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        UIApplication.updateAppearance(reactor.currentState.appearance)
      }).disposed(by: disposeBag)
  }
}

// MARK: - UITableViewDataSource
extension FeedSettingViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    FeedSettingSection.allCases.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch FeedSettingSection(rawValue: section)! {
    case .user: return userItems.count
    case .etc: return etcItems.count
    }
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let settingSection = FeedSettingSection(rawValue: section) else { return nil }
    let label = UILabel()
    label.font = .appleSDGothicNeo(.medium, size: 18)
    label.textColor = .palette(.title)
    label.setAutoLayout()
    label.text = {
      switch settingSection {
      case .user: return "사용자 설정"
      case .etc: return "기타"
      }
    }()
    
    let container = UIView()
    container.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
      label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
    ])
    
    return container
  }
}

// MARK: - TableViewDelegate
extension FeedSettingViewController {
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let settingSection = FeedSettingSection(rawValue: indexPath.section) else { return .init() }
    if settingSection == .user {
      let cell = tableView.dequeueReusableCell(for: indexPath, type: FeedSettingDisplayCell.self)
      cell?.segmentTap = { [weak self] selectedIndex in
        guard let self else { return }
        
        guard let appearance = DisplayAppearance(rawValue: selectedIndex) else {
          assertionFailure("이거 세그먼트 3개로 고정되어야함. 확인바람")
          return
        }
        reactor?.action.onNext(.displayAppearanceUpdated(appearance))
        
      }
      guard let reactor else { return .init() }
      cell?.configure(with: reactor.currentState.appearance.rawValue)
      cell?.textLabel?.text = userItems[indexPath.row]
      return cell ?? .init()
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    /// initial setup
    if cell.textLabel?.textColor != .palette(.primaryNuetralText) {
      cell.backgroundColor = .clear
      cell.selectionStyle = .none
      cell.textLabel?.font = .appleSDGothicNeo(.regular, size: 14)
      cell.textLabel?.textColor = .palette(.primaryNuetralText)
    }
    
    /// configure
    cell.textLabel?.text = etcItems[indexPath.row]
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 21
  }
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footerView = UIView()
    footerView.backgroundColor = .clear
    
    if section == FeedSettingSection.user.rawValue {
      let line = UIView(frame: .zero).then {
        $0.setAutoLayout()
        $0.backgroundColor = .palette(.sectionDivideLine)
      }
      
      line.translatesAutoresizingMaskIntoConstraints = false
      line.backgroundColor = .palette(.sectionDivideLine)
      footerView.addSubview(line)
      NSLayoutConstraint.activate([
        line.leadingAnchor.constraint(equalTo: footerView.leadingAnchor),
        line.trailingAnchor.constraint(equalTo: footerView.trailingAnchor),
        line.heightAnchor.constraint(equalToConstant: 2),
        line.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 32)
      ])
    }
    
    return footerView
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let settingSection = FeedSettingSection(rawValue: indexPath.section) else { return }
    switch settingSection {
    case .user:
      break
    case .etc:
       if indexPath.row == 0 {
        flowDependencies.showQnAMailPage()
      } else if indexPath.row == 1 {
        flowDependencies.showOpenSourcesPage()
      } else {
        flowDependencies.showCreditsPage()
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return section == FeedSettingSection.user.rawValue ? 59 : 0
  }
}
