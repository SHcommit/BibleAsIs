//
//  BaseOnboardingView.swift
//  BibleAsIs
//
//  Created by 양승현 on 4/13/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import DesignSystem

final class BaseOnboardingView: BaseView {
  private let titles = TitleSubtitleView(
    axis: .vertical,
    spacing: 7,
    titleLabelFactory: {
      $0.font = .appleSDGothicNeo(.bold, size: 20)
      $0.textColor = .palette(.title)
      $0.textAlignment = .center
    }, subtitleLabelFactory: {
      $0.font = .appleSDGothicNeo(.regular, size: 14)
      $0.textColor = .palette(.description)
      $0.textAlignment = .center
      $0.numberOfLines = 2
    }
  ).then {
    $0.setAutoLayout()
    $0.alignment = .center
  }
  
  private let imageView = UIImageView(frame: .zero).then {
    $0.setAutoLayout()
    $0.setScaleAspectFit()
  }
  
  override func layoutUI() {
    super.layoutUI()
    addSubviews([titles, imageView])
    NSLayoutConstraint.activate([
      titles.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
      titles.centerXAnchor.constraint(equalTo: centerXAnchor)
    ])
  }
  
  func configure(title: String, subtitle: String, imageViewLayoutFactory: (UIImageView) -> Void) {
    self.titles.configure(title: title, subtitle: subtitle)
    imageViewLayoutFactory(imageView)
  }
}
