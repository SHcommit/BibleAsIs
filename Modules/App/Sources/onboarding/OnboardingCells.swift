//
//  OnboardingGardenCell.swift
//  BibleAsIs
//
//  Created by 양승현 on 4/13/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import DesignSystem

/// 61 + 16 == 77 만큼의 spacing이 있어야함
final class OnboardingCell1: UICollectionViewCell {
  private let onboardingView = BaseOnboardingView(frame: .zero).then {
    $0.setAutoLayout()
    $0.configure(title: "말씀의 정원", subtitle: "성경책을 읽거나,\n챌린지 활동을 통해 흔적을 남길 수 있어요!", imageViewLayoutFactory: { iv in
      guard let ivSuperView = iv.superview else { assertionFailure("부모뷰에 추가부터 해야함"); return }
      iv.setImage(image: DesignSystemAsset.Image.onboarding1Garden.image)
      iv.setScaleAspectFit()
      NSLayoutConstraint.activate([
        iv.leadingAnchor.constraint(equalTo: ivSuperView.leadingAnchor),
        iv.trailingAnchor.constraint(equalTo: ivSuperView.trailingAnchor),
        iv.heightAnchor.constraint(equalToConstant: 456),
        iv.centerYAnchor.constraint(equalTo: ivSuperView.centerYAnchor, constant: -30)
      ])
    })
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(onboardingView)
    clipsToBounds = true
    backgroundColor = .clear
    NSLayoutConstraint.activate([
      onboardingView.leadingAnchor.constraint(equalTo: leadingAnchor),
      onboardingView.topAnchor.constraint(equalTo: topAnchor),
      onboardingView.trailingAnchor.constraint(equalTo: trailingAnchor),
      onboardingView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) { nil }
}

final class OnboardingCell2: UICollectionViewCell {
  private let onboardingView = BaseOnboardingView(frame: .zero).then {
    $0.setAutoLayout()
    $0.configure(title: "오늘의 말씀 묵상", subtitle: "하나님의 주권은 오늘도 변함없어요.\n그 말씀을 함께 묵상해요.", imageViewLayoutFactory: { iv in
      guard let ivSuperView = iv.superview else { assertionFailure("부모뷰에 추가부터 해야함"); return }
      iv.setImage(image: DesignSystemAsset.Image.onboarding2RandomVerse.image)
      iv.setScaleAspectFit()
      NSLayoutConstraint.activate([
        iv.heightAnchor.constraint(equalToConstant: 211),
        iv.leadingAnchor.constraint(equalTo: ivSuperView.leadingAnchor),
        iv.trailingAnchor.constraint(equalTo: ivSuperView.trailingAnchor),
        iv.centerXAnchor.constraint(equalTo: ivSuperView.centerXAnchor),
        iv.centerYAnchor.constraint(equalTo: ivSuperView.centerYAnchor, constant: -10)
      ])
    })
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(onboardingView)
    clipsToBounds = true
    backgroundColor = .clear
    NSLayoutConstraint.activate([
      onboardingView.leadingAnchor.constraint(equalTo: leadingAnchor),
      onboardingView.topAnchor.constraint(equalTo: topAnchor),
      onboardingView.trailingAnchor.constraint(equalTo: trailingAnchor),
      onboardingView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) { nil }
}

final class OnboardingCell3: UICollectionViewCell {
  private let onboardingView = BaseOnboardingView(frame: .zero).then {
    $0.setAutoLayout()
    $0.configure(title: "성경 구절 묵상", subtitle: "하트, 노트, 하이라이트를 통해\n하나님의 말씀으로 마음을 채워보세요.", imageViewLayoutFactory: { iv in
      guard let ivSuperView = iv.superview else { assertionFailure("부모뷰에 추가부터 해야함"); return }
      iv.setImage(image: DesignSystemAsset.Image.onboarding3BibleReading.image)
      iv.setScaleAspectFill()
      NSLayoutConstraint.activate([
        iv.heightAnchor.constraint(equalToConstant: 345),
        iv.leadingAnchor.constraint(equalTo: ivSuperView.leadingAnchor, constant: 16),
        iv.trailingAnchor.constraint(equalTo: ivSuperView.trailingAnchor, constant: -16),
        iv.centerYAnchor.constraint(equalTo: ivSuperView.centerYAnchor, constant: -30)
//        iv.bottomAnchor.constraint(equalTo: ivSuperView.bottomAnchor, constant: -120)
        
      ])
    })
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(onboardingView)
    clipsToBounds = true
    NSLayoutConstraint.activate([
      onboardingView.leadingAnchor.constraint(equalTo: leadingAnchor),
      onboardingView.topAnchor.constraint(equalTo: topAnchor),
      onboardingView.trailingAnchor.constraint(equalTo: trailingAnchor),
      onboardingView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) { nil }
}

final class OnboardingCell4: UICollectionViewCell {
  private let onboardingView = BaseOnboardingView(frame: .zero).then {
    $0.setAutoLayout()
    $0.configure(title: "맥체인 데일리 챌린지", subtitle: "하루 4장, 꾸준히 읽으면\n성경 전체를 완독할 수 있어요.", imageViewLayoutFactory: { iv in
      guard let ivSuperView = iv.superview else { assertionFailure("부모뷰에 추가부터 해야함"); return }
      iv.setImage(image: DesignSystemAsset.Image.onboarding4MccCheyne.image)
      iv.setScaleAspectFill()
      NSLayoutConstraint.activate([
        iv.heightAnchor.constraint(equalToConstant: 330),
        iv.leadingAnchor.constraint(equalTo: ivSuperView.leadingAnchor),
        iv.trailingAnchor.constraint(equalTo: ivSuperView.trailingAnchor),
        iv.centerYAnchor.constraint(equalTo: ivSuperView.centerYAnchor)
      ])
    })
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(onboardingView)
    clipsToBounds = true
    backgroundColor = .clear
    NSLayoutConstraint.activate([
      onboardingView.leadingAnchor.constraint(equalTo: leadingAnchor),
      onboardingView.topAnchor.constraint(equalTo: topAnchor),
      onboardingView.trailingAnchor.constraint(equalTo: trailingAnchor),
      onboardingView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) { nil }
}

final class OnboardingCell5: UICollectionViewCell {
  private let onboardingView = BaseOnboardingView(frame: .zero).then {
    $0.setAutoLayout()
    $0.configure(title: "성경 통독 체크리스트", subtitle: "한 걸음씩,\n말씀 속 은혜로 나아가요", imageViewLayoutFactory: { iv in
      guard let ivSuperView = iv.superview else { assertionFailure("부모뷰에 추가부터 해야함"); return }
      iv.setImage(image: DesignSystemAsset.Image.onboarding5ReadingChecklist1.image)
      iv.setScaleAspectFill()
      NSLayoutConstraint.activate([
        iv.heightAnchor.constraint(equalToConstant: 392),
        iv.leadingAnchor.constraint(equalTo: ivSuperView.leadingAnchor, constant: 16),
        iv.trailingAnchor.constraint(equalTo: ivSuperView.trailingAnchor, constant: -16),
        iv.centerXAnchor.constraint(equalTo: ivSuperView.centerXAnchor),
        iv.centerYAnchor.constraint(equalTo: ivSuperView.centerYAnchor, constant: -30)
//        iv.bottomAnchor.constraint(equalTo: ivSuperView.bottomAnchor, constant: -90)
      ])
    })
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(onboardingView)
    clipsToBounds = true
    backgroundColor = .clear
    NSLayoutConstraint.activate([
      onboardingView.leadingAnchor.constraint(equalTo: leadingAnchor),
      onboardingView.topAnchor.constraint(equalTo: topAnchor),
      onboardingView.trailingAnchor.constraint(equalTo: trailingAnchor),
      onboardingView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) { nil }
}
