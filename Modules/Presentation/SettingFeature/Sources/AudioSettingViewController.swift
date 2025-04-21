//
//  AudioSettingViewController.swift
//  SettingFeature
//
//  Created by 양승현 on 3/16/25.
//

import UIKit
import DomainEntity
import DesignSystem
import SettingInterface

public final class AudioSettingCell: UITableViewCell {
  private let label = UILabel(frame: .zero).then {
    $0.setAutoLayout()
    $0.font = .appleSDGothicNeo(.light, size: 13)
    $0.textColor = .palette(.primaryNuetralText)
    $0.textAlignment = .center
    $0.backgroundColor = .clear
  }
  
  public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.backgroundColor = .clear
    backgroundColor = .clear
    contentView.addSubview(label)
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      label.topAnchor.constraint(equalTo: contentView.topAnchor),
      label.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
      label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  public func configure(with text: String) { label.text = text }
}

public final class AudioSettingViewController: BaseViewController {
  // MARK: - Properties
  private let titleLabel = UILabel(frame: .zero).then {
    $0.setAutoLayout()
    $0.text = "취침 오디오 타이머 설정"
    $0.font = .appleSDGothicNeo(.medium, size: 18)
    $0.textColor = .palette(.title)
  }
  
  private(set) var tableview = UITableView(frame: .zero, style: .plain).then {
    $0.setAutoLayout()
    $0.register(AudioSettingCell.self)
    $0.rowHeight = 40
    $0.backgroundColor = .clear
  }
  
  private(set) var options: [SleepTimerOption] = SleepTimerOption.allCases
  
  private let blurView = BaseBlurView(style: .prominent, opacity: 0.95).setAutoLayout()
  
  private let waveView = WaveView(frame: .zero).setAutoLayout()
  
  public var ownerPickSleepTimerOptionHandler: ((SleepTimerOption) -> Void)?
  
  // 사용자가 선택한 오디오 플레이시간이 없으면 테이블뷰 아무것도 체크 노노!
  private(set) var sleepTimerDuration: SleepTimerOption?
  
  /// Coordiantor특성상 누군가 강하게 참조해야만 그 생명이 유지됨.
  ///
  /// 지금같은 경우 따로 parentCoordinator가 child를 own하지 않게되니, SettingVC가 사라지면 SettingCoordinator도 사라짐.
  /// 그럼 AudioSettingVC의 ownerPickSleepTimerOptionhandler는 SettingCoordiantor에서 선언했지만 settingVC특성상 present된게 사라져서, 코디네이터도 사라지고,
  /// 캡쳐했던 handler구현체가 사라져버리는것임.
  private var flowDependencies: SettingFlowDependencies
  
  // MARK: - Lifecycle
  public init(sleepTimerDuration: SleepTimerOption?, flowDependencies: SettingFlowDependencies) {
    self.sleepTimerDuration = sleepTimerDuration
    self.flowDependencies = flowDependencies
    super.init(nibName: nil, bundle: nil)
    tableview.dataSource = self
    tableview.delegate = self
    setSheetStyle()
  }
  
  @available(*, deprecated)
  required public init?(coder: NSCoder) {
    nil
  }
  
  public override func viewDidLoad() {
    waveView.configureWave(
      height: 50, speed: 0.005, frequency: 0.5,
      firstColor: .systemGray4.withAlphaComponent(0.5),
      secondColor: .systemGray3.withAlphaComponent(0.5))
    super.viewDidLoad()
    view.backgroundColor = .clear
    tableview.reloadData()
  }

  public override func layoutUI() {
    [blurView, titleLabel, tableview, waveView].forEach(view.addSubview(_:))
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
      titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      
      tableview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      tableview.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
      tableview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      tableview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      
      blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      blurView.topAnchor.constraint(equalTo: view.topAnchor),
      blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      waveView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      waveView.heightAnchor.constraint(equalToConstant: 60),
      waveView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      waveView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  func updateSleepOption(_ option: SleepTimerOption) {
    sleepTimerDuration = option
  }
  
  func playAudioSleepTime() {
    guard let option = sleepTimerDuration else { return }
    ownerPickSleepTimerOptionHandler?(option)
    dismiss(animated: true)
  }
  
  public func setSheetStyle() {
    if #available(iOS 15.0, *) {
      if let sheet = sheetPresentationController {
        sheet.detents = [.medium(), .large() ]
        sheet.prefersGrabberVisible = true
        sheet.preferredCornerRadius = 21
      } else {
        modalPresentationStyle = .formSheet
      }
    } else {
      modalPresentationStyle = .formSheet
    }
  }
}

extension AudioSettingViewController: UITableViewDataSource {
  public func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    SleepTimerOption.numberOfOptions
  }
  
  public func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    let current = options[indexPath.row]
    let cell = tableView.dequeueReusableCell(for: indexPath, type: AudioSettingCell.self)
    cell?.configure(with: current.rawValue)
    if let sleepTimerDuration {
      cell?.accessoryType = (current == sleepTimerDuration) ? .checkmark : .none
    }
    return cell ?? .init()
  }
}

extension AudioSettingViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    /// 이전에 선택했던게 존재한다면
    if let prevOption = sleepTimerDuration {
      guard let prevSelectedIndex = options.firstIndex(where: {$0 == prevOption}) else {
        assertionFailure("특정한 옵션이 반드시 나와야하는데, prevOption: \(prevOption)옵션 확인바람"); return
      }
      let prevIndexPath = IndexPath(row: prevSelectedIndex, section: 0)
      
      if prevIndexPath == indexPath {
        ToastController.shared.showToast(message: "새로운 타이머를 선택해주세요", type: .warning)
        return
      }
      updateSleepOption(options[indexPath.row])
      tableView.cellForRow(at: prevIndexPath)?.accessoryType = .none
      tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
      tableView.reloadRows(at: [prevIndexPath, indexPath], with: .automatic)
      playAudioSleepTime()
      return
    }
    updateSleepOption(options[indexPath.row])
    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    tableView.reloadRows(at: [indexPath], with: .automatic)
    playAudioSleepTime()
  }
}
