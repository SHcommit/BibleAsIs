//
//  FeedCreditsViewController.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 4/11/25.
//

import Then
import UIKit

final class FeedCreditCell: UITableViewCell {
  let titleLabel = UILabel().then {
    $0.setAutoLayout()
    $0.font = .appleSDGothicNeo(.regular, size: 14)
    $0.textColor = .palette(.primaryNuetralText)
    $0.numberOfLines = 0
  }
  
  let subtitleLabel = UILabel().then {
    $0.setAutoLayout()
    $0.font = .appleSDGothicNeo(.regular, size: 12)
    $0.textColor = .palette(.primaryColor)
    $0.numberOfLines = 0
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    backgroundColor = .clear
    selectionStyle = .none
    
    [titleLabel, subtitleLabel].forEach(contentView.addSubview(_:))
    let slc = subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
    slc.priority = .init(777)
    
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      
      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
      subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
      subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
      slc])
  }

  @available(*, deprecated)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(title: String, subtitle: String) {
    titleLabel.text = title
    let attributedString = NSAttributedString(
      string: subtitle,
      attributes: [
        .foregroundColor: UIColor.palette(.primaryColor),
        .underlineStyle: NSUnderlineStyle.single.rawValue])
    
    subtitleLabel.attributedText = attributedString
  }
}

final class FeedCreditsViewController: UITableViewController {
  private var titles: [String] = [
    "[대한성서공회]개역한글판",
    "[Lottie]LottieFiles",
    "ICONS",
    "[unDraw]illustrations",
    "Usplash",
    "[Font]AppleSDGothicNeo",
    "[Font]Kavivanar"
  ]
  
  private var subtitles: [String] = [
    "https://www.bskorea.or.kr/prog/trans_feature2.php",
    "https://lottiefiles.com/kr/free-animation",
    "https://icons8.kr/icons",
    "https://undraw.co/illustrations/",
    "https://unsplash.com/ko",
    "https://github.com/fonts-archive/AppleSDGothicNeo",
    "https://fonts.google.com/specimen/Kavivanar"
  ]
  
  init() {
    super.init(style: .plain)
    tableView.backgroundColor = .palette(.appearance)
    navigationItem.title = "Credits"
    tableView.register(FeedCreditCell.self)
    tableView.separatorStyle = .none
    tableView.rowHeight = UITableView.automaticDimension
    tableView.backgroundColor = .palette(.appearance)
    tableView.delaysContentTouches = false
    tableView.contentInset = .init(top: 20, left: 0, bottom: 0, right: 0)
    tableView.backgroundColor = .palette(.appearance)
    tableView.scrollIndicatorInsets = .init(top: 0, left: 0.7, bottom: 0, right: 0)
    tableView.dataSource = self
    tableView.delegate = self
    
    if #available(iOS 15.0, *) {
      tableView.sectionHeaderTopPadding = 0
    }
  }
  
  @available(*, deprecated)
  required init?(coder: NSCoder) { nil }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    tableView.reloadData()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.interactivePopGestureRecognizer?.isEnabled = true
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    titles.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(for: indexPath, type: FeedCreditCell.self)
    cell?.configure(title: titles[indexPath.row], subtitle: subtitles[indexPath.row])
    return cell ?? .init()
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if let url = URL(string: subtitles[indexPath.row]) {
      UIApplication.shared.open(url)
    }
  }
}
