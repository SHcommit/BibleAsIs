//
//  SleepTimerViewController.swift
//  JourneyOfFaithCatalogApp
//
//  Created by 양승현 on 2/8/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Core
import UIKit
import DesignSystem
import DomainEntity

//
// public class SleepTimerViewController: UIViewController {
//  private var isPlaying = false
//  
//  private lazy var playButton: UIButton = {
//    let button = UIButton(type: .system)
//    button.translatesAutoresizingMaskIntoConstraints = false
//    button.setTitle("읽기 시작", for: .normal)
//    button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//    button.setTitleColor(.white, for: .normal)
//    button.backgroundColor = .blue
//    button.layer.cornerRadius = 10
//    button.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
//    return button
//  }()
//  
//  public override func viewDidLoad() {
//    super.viewDidLoad()
//    view.backgroundColor = .white
//    setupUI()
//  }
//  
//  private func setupUI() {
//    view.addSubview(playButton)
//    NSLayoutConstraint.activate([
//      playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//      playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//      playButton.widthAnchor.constraint(equalToConstant: 200),
//      playButton.heightAnchor.constraint(equalToConstant: 50)
//    ])
//  }
//  
//  @objc private func didTapPlayButton() {
//    if isPlaying {
//      playButton.setTitle("읽기 시작", for: .normal)
//      playButton.backgroundColor = .blue
//    } else {
//      let pickerVC = SleepOptionPickerViewController()
//      pickerVC.presentPicker(in: self, completion: {
//        let verses: [BibleVerse] = ((0..<10).map {
//          .init(book: "창세기", chapter: 1, verse: $0, content: "그 때에 왕의 서기관들이 왕의 명령을 따라 제삼 달 곧 십일일에 왕의 도장을 찍고, 각 지방 백성들의 언어와 각 민족들의 글로 된 법령을 제시하여, 왕의 명령을 전하게 되었다. 모든 도시는 각 민족과 각 방언에 따라 작성되었으며, 그것은 왕의 명령에 따라 모든 사람들이 각자의 요구를 만족시킬 수 있도록 하기 위해서였다.")
//        })
//      })
//      playButton.setTitle("정지", for: .normal)
//      playButton.backgroundColor = .red
//    }
//    isPlaying.toggle()
//  }
// }
