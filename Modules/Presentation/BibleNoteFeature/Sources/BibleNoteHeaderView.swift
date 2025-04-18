//
//  BibleNoteHeaderView.swift
//  BibleNoteFeature
//
//  Created by 양승현 on 3/9/25.
//

import UIKit
import DomainEntity
import DesignSystem

public final class BibleNoteHeaderView: BaseView {
  // MARK: - Properteis
  private lazy var cardView = QuotationWithVertiBarBibleVerseView(
    frame: .zero,
    shouldShowBorder: false,
    shouldShowShadow: false,
    shouldUseAppearAnimation: true,
    verseLabelFactory: { $0.font = .appleSDGothicNeo(.light, size: 14) },
    quotationVertiBarWidth: 2,
    wannaEqualToLayoutBookChapterVerseLabelBottomConstraint: true
  ).then {
    $0.setAutoLayout()
    $0.layer.cornerRadius = 0
    $0.layer.borderWidth = 0
  }
  
  private let dateLabel = UILabel(frame: .zero).then {
    $0.setAutoLayout()
    $0.textColor = .palette(.description)
    $0.font = .appleSDGothicNeo(.medium, size: 11)
    $0.textAlignment = .center
    $0.alpha = 0
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "yyyy년 M월 d일"
    $0.text = formatter.string(from: Date())
  }
  
  private let lineView = UIView(frame: .zero).then {
    $0.setAutoLayout()
    $0.backgroundColor = .palette(.sectionDivideLine)
    $0.alpha = 0
  }
  
  private let noteHeaderLabel = UILabel(frame: .zero).then {
    $0.setAutoLayout()
    $0.alpha = 0
    $0.text = "Notes :"
    $0.font = .appleSDGothicNeo(.medium, size: 11)
    $0.textColor = .palette(.description)
  }
  
  // MARK: - Lifecycle
  public override init(frame: CGRect) {
    super.init(frame: frame)
    [cardView, dateLabel, lineView, noteHeaderLabel].forEach(addSubview(_:))
    NSLayoutConstraint.activate([
      cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
      cardView.topAnchor.constraint(equalTo: topAnchor, constant: 7),
      cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
      dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      dateLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
      
      lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
      lineView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
      lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
      lineView.heightAnchor.constraint(equalToConstant: 5),
      
      noteHeaderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      noteHeaderLabel.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 32),
      noteHeaderLabel.bottomAnchor.constraint(equalTo: bottomAnchor)])
    
    updateAppearance()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Helpers
  public func animate(with reference: BibleVerse? = nil, completion: (() -> Void)? = nil) {
    cardView.animate(with: reference) { [weak self] in
      guard let self else { return }
      dateLabel.fadeInFromBottomUIViewVer(delay: 0.1, initialOffsetY: 2)
      lineView.fadeInFromBottomUIViewVer(delay: 0.2, initialOffsetY: 1)
      noteHeaderLabel.fadeInFromBottomUIViewVer(delay: 0.3, initialOffsetY: 2)
      completion?()
    }
  }
  
  public func cancelBibleVerseTypingAnimation() {
    cardView.cancelBibleVerseTypingAnimation()
  }
  
//  override public func updateAppearance() {
//    super.updateAppearance()
//    if traitCollection.userInterfaceStyle == .dark {
//      lineView.backgroundColor = .init(hexCode: "#555555").withAlphaComponent(0.16)
//    } else {
//      lineView.backgroundColor = .init(hexCode: "#B3B3B3").withAlphaComponent(0.16)
//    }
//  }
}
