//
//  LaunchScreenViewController.swift
//  BibleAsIs
//
//  Created by 양승현 on 4/17/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Then
import UIKit
import DesignSystem

final class LaunchScreenViewController: BaseViewController {
  private let appLogoIcon = UIImageView(frame: .zero).then {
    $0.setAutoLayout()
    $0.image = UIImage(named: "AppIconWithoutBgLarge")
    $0.setScaleAspectFit()
  }
  
  private let appNameLabel = UILabel(frame: .zero).then {
    $0.setAutoLayout()
    $0.text = "성경대로"
    $0.font = .appleSDGothicNeo(.bold, size: 20)
    $0.textColor = .white
    $0.textAlignment = .center
  }
  
  private let indicator = UIActivityIndicatorView(style: .medium).then {
    $0.setAutoLayout()
    $0.color = .palette(.primaryColor)
    $0.hidesWhenStopped = true
  }
  
  private let descriptionLabel = UILabel(frame: .zero).then {
    $0.setAutoLayout()
    $0.text = "Bible\n대한성서공회"
    $0.font = .appleSDGothicNeo(.regular, size: 14)
    $0.textAlignment = .center
    $0.numberOfLines = 2
    $0.isHidden = true
    $0.textColor = .init(hexCode: "B3B3B3")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .init(hexCode: "2C3D4D")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    indicator.startAnimating()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    indicator.stopAnimating()
  }
  
  override func layoutUI() {
    super.layoutUI()
    let _subviews = [appLogoIcon, appNameLabel, indicator, descriptionLabel]
    _subviews.forEach(view.addSubview)
    _subviews.forEach {
      $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    NSLayoutConstraint.activate([
      appLogoIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -24),
      appLogoIcon.widthAnchor.constraint(equalToConstant: 140),
      appLogoIcon.heightAnchor.constraint(equalToConstant: 140),
      
      appNameLabel.topAnchor.constraint(equalTo: appLogoIcon.bottomAnchor, constant: 7),
      
      descriptionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28),
      indicator.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -22)
    ])
  }
}
