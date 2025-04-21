//
//  FeedSettingDisplayCell.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 4/10/25.
//

import Then
import UIKit

final class FeedSettingDisplayCell: UITableViewCell {
  private lazy var segmentControl = UISegmentedControl(items: ["자동", "라이트", "다크"]).then {
    $0.setAutoLayout()
    $0.selectedSegmentIndex = 0
    $0.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    $0.setTitleTextAttributes([.foregroundColor: UIColor.palette(.title)], for: .normal)
  }
  
  var prevSegmentControlIndex = 0
  
  var segmentTap: ((Int) -> Void)?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    textLabel?.font = .appleSDGothicNeo(.regular, size: 14)
    textLabel?.textColor = .palette(.primaryNuetralText)
    backgroundColor = .clear
    addSubview(segmentControl)
    NSLayoutConstraint.activate([
      segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      segmentControl.centerYAnchor.constraint(equalTo: centerYAnchor),
      segmentControl.heightAnchor.constraint(equalToConstant: 32)
    ])
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) { nil }
  
  func configure(with selectedIndex: Int) {
    self.segmentControl.selectedSegmentIndex = selectedIndex
    prevSegmentControlIndex = selectedIndex
  }
  
  @objc private func segmentChanged(_ sender: UISegmentedControl) {
    if prevSegmentControlIndex == sender.selectedSegmentIndex { return }
    prevSegmentControlIndex = sender.selectedSegmentIndex
    segmentTap?(prevSegmentControlIndex)
  }
}
