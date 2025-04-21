//
//  BibleFeedChallengeCell.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 3/20/25.
//

import UIKit
import BibleMccCheyneChallengeInterface

public final class BibleFeedChallengeCell: UITableViewCell {
  // MARK: - Properties
  private var spacer = UIView(frame: .zero).setAutoLayout()
  
  private var mccCheyneChallengeView: UIViewController!
  
  // MARK: - Lifecycle
  public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = .none
    backgroundColor = .clear
    contentView.backgroundColor = .clear
    layoutUI()
  }
  
  @available(*, deprecated)
  required public init?(coder: NSCoder) { nil }
  
  // MARK: - Layout
  private func layoutUI() {
    contentView.addSubview(spacer)
    let bc = spacer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    bc.priority = .init(777)
    NSLayoutConstraint.activate([
      spacer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      spacer.topAnchor.constraint(equalTo: contentView.topAnchor),
      spacer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      spacer.heightAnchor.constraint(equalToConstant: BibleMccCheyneChallengeConstraints.mccCheyneChallengeHeight),
      bc])
  }
  
  // MARK: - Helpers
  /// gateway를 통해서 mccCheyneChallengeViewController를 주입해주어야함.
  func configure(with mccCheyneChallengeViewFactory: (() -> UIViewController)) {
    if mccCheyneChallengeView == nil {
      mccCheyneChallengeView = mccCheyneChallengeViewFactory()
      let challengeView: UIView! = mccCheyneChallengeView.view
      challengeView.setAutoLayout()
      contentView.addSubview(challengeView)
      let bc = mccCheyneChallengeView.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
      NSLayoutConstraint.activate([
        challengeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        challengeView.heightAnchor.constraint(
          equalToConstant: BibleMccCheyneChallengeConstraints.mccCheyneChallengeHeight),
        challengeView.topAnchor.constraint(equalTo: contentView.topAnchor),
        challengeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        bc
      ])
      challengeView.fadeInFromBottom(initialOffsetY: 7)
    }
  }
  
  public func reloadData() {
    (mccCheyneChallengeView as? BibleMccCheyneRefreshable)?.reloadData()
  }
}
