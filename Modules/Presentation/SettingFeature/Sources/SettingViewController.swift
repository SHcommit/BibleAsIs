//
//  SettingViewController.swift
//  SettingFeature
//
//  Created by 양승현 on 3/11/25.
//

import Common
import UIKit
import RxSwift
import ReactorKit
import DesignSystem
import DomainEntity
import SettingInterface

public final class SettingViewController: BaseViewController, View {
  public typealias Reactor = SettingReactor
  
  // MARK: - Properties
  private let titleLabel = UILabel(frame: .zero).then {
    $0.setAutoLayout()
    $0.text = "시스템 설정"
    $0.font = .appleSDGothicNeo(.medium, size: 18)
    $0.textColor = .palette(.title)
  }
  
  private let settingView = UserInterfaceSettingView().setAutoLayout()
  
  private let blurView = BaseBlurView(style: .prominent, opacity: 0.95).setAutoLayout()
  
  private let waveView = WaveView(frame: .zero).setAutoLayout()
  
  private(set) var delegate: SettingViewControllerDelegate?
  
  public var disposeBag = DisposeBag()
  
  public init(delegate: SettingViewControllerDelegate?) {
    self.delegate = delegate
    super.init(nibName: nil, bundle: nil)
    setSheetStyle()
  }
  
  @available(*, deprecated)
  required public init?(coder: NSCoder) {
    nil
  }
  
  // MARK: - Lifecycle
  public override func viewDidLoad() {
    waveView.configureWave(
      height: 50, speed: 0.005, frequency: 0.5,
      firstColor: .systemGray4.withAlphaComponent(0.5),
      secondColor: .systemGray3.withAlphaComponent(0.5))
    super.viewDidLoad()
    view.backgroundColor = .clear
    settingView.delegate = self
    reactor?.action.onNext(.refresh)
  }

  public override func layoutUI() {
    [blurView, titleLabel, settingView, waveView].forEach(view.addSubview(_:))
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
      titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      
      settingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      settingView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
      settingView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      settingView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
      
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
  
  // MARK: - Bind
  public func bind(reactor: Reactor) {
    reactor.state
      .map { $0.appearanceUpdated }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { updatedAppearance in
        guard updatedAppearance else { return }
        UIApplication.updateAppearance(reactor.appearance)
      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.fontUpdated }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] updatedFontSize in
        guard updatedFontSize else { return }
        self?.delegate?.handleUpdatedFontSize(reactor.fontSize)

      }).disposed(by: disposeBag)
    
    reactor.state
      .map { $0.shouldRefresh }
      .distinctUntilChanged()
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] shouldRefresh in
        guard shouldRefresh else { return }
        let fontSize = reactor.fontSize
        let appearance = reactor.appearance
        self?.settingView.configure(userPickFontSize: fontSize, userPickAppearance: appearance)
      }).disposed(by: disposeBag)
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
