//
//  BibleReadingChecklistViewController+Helpers.swift
//  BibleReadingChecklistFeature
//
//  Created by 양승현 on 3/27/25.
//

import UIKit

extension BibleReadingChecklistViewController {
  func makeBlurNaviView() -> UIView {
    let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: .fill)
    let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
    
    let navView = UIView()
    navView.alpha = 0
    navView.backgroundColor = .clear
    navView.translatesAutoresizingMaskIntoConstraints = false
    
    blurEffectView.translatesAutoresizingMaskIntoConstraints = false
    blurEffectView.contentView.addSubview(vibrancyEffectView)
    vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = false
    
    navView.addSubview(blurEffectView)
    
    NSLayoutConstraint.activate([
      blurEffectView.leadingAnchor.constraint(equalTo: navView.leadingAnchor),
      blurEffectView.topAnchor.constraint(equalTo: navView.topAnchor),
      blurEffectView.trailingAnchor.constraint(equalTo: navView.trailingAnchor),
      blurEffectView.bottomAnchor.constraint(equalTo: navView.bottomAnchor),
      
      vibrancyEffectView.leadingAnchor.constraint(equalTo: blurEffectView.contentView.leadingAnchor),
      vibrancyEffectView.topAnchor.constraint(equalTo: blurEffectView.contentView.topAnchor),
      vibrancyEffectView.trailingAnchor.constraint(equalTo: blurEffectView.contentView.trailingAnchor),
      vibrancyEffectView.bottomAnchor.constraint(equalTo: blurEffectView.contentView.bottomAnchor)
    ])
    
    navView.layer.borderColor = UIColor.lightGray.cgColor
    navView.layer.borderWidth = 0.1
    view.addSubview(navView)
    NSLayoutConstraint.activate([
      navView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -1),
      navView.topAnchor.constraint(equalTo: view.topAnchor, constant: -1),
      navView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 1),
      navView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44)
    ])
    view.bringSubviewToFront(backButton)
    view.bringSubviewToFront(titleLabel)
    return navView
  }
}
