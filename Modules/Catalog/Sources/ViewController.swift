//
//  ViewController.swift
//  JourneyOfFaithCatalogApp
//
//  Created by 양승현 on 1/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import Then
import DesignSystem
import DesignSystemItems

class ViewController: UIViewController {
  private var horiCarouselView: HorizontalVerseCarouselView!
  
  private let scrollView = UIScrollView(frame: .zero).then {
    $0.translatesAutoresizingMaskIntoConstraints = false
  }
  
  private let stackView = UIStackView(frame: .zero).then {
    $0.axis = .vertical
    $0.alignment = .fill
    $0.distribution = .equalSpacing
    $0.spacing = 30
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.clipsToBounds = false
    $0.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: 16, right: 16)
    $0.isLayoutMarginsRelativeArrangement = true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .palette(.appearance)
    layoutUI()
    addComponents()
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    injectData()
  }
  
  func injectData() {
    configHoriCarouselView()
    dataSourc = 150
    
    let _dataSource2 = (1...150).map {
      TestamentOfBookChapterItem(chapterNumber: $0, isClipped: ($0%20 == 0 && $0/20 == 1))
    }
    expendedTestamentOfBookAccordionView.configure(_dataSource2)
    expendedTestamentOfBookAccordionView.reloadData()
  }
  
  private func addComponents() {
    showBibleLabel()
    setOldTestamentOfbibleAccordionView()
    setNewTestamentOfbibleAccordionView()
    setClippedOldTestamentOfbibleAccordionView()
    setClippedNewTestamentOfbibleAccordionView()
    
    setTestamentOfBookAccordionView()
    
    setVerticalChapterVerseWithBlurView()
    setHorizontalVerseCarouselView()
    
    setIconTextTag()
    
    setSearchedChapterVerseCardView()
    
    setExpendedTestamentOfBookAccordionView()
    
    baseComponent_NumerousSHadowContainerView()
    
    setNormalChapterVerseCardView()
    
    setSearchedVersesHistoryView()
    setCheckbox()
    showDailyChallengeView()
//     setLampView()
  }
  
  var colV: UICollectionView!
  
  var colVHeight: NSLayoutConstraint!
  
  var dataSourc = 0
  
  var expendedTestamentOfBookAccordionView: ExpandedTestamentOfBookAccordionView!
}

extension ViewController {
  func setOldTestamentOfbibleAccordionView() {
    _=TestamentOfBibleAccordionView(testamentType: .old).then {
      $0.configure(title: "구약 성경", subtitle: "39 Books")
      $0.translatesAutoresizingMaskIntoConstraints = true
      $0.heightAnchor.constraint(equalToConstant: 77).isActive = true
      stackView.addArrangedSubview($0)
    }
  }
  
  func setNewTestamentOfbibleAccordionView() {
    _=TestamentOfBibleAccordionView(testamentType: .new).then {
      $0.configure(title: "신약 성경", subtitle: "27 Books")
      $0.translatesAutoresizingMaskIntoConstraints = true
      $0.heightAnchor.constraint(equalToConstant: 77).isActive = true
      stackView.addArrangedSubview($0)
    }
  }
  
  func setClippedOldTestamentOfbibleAccordionView() {
    _=TestamentOfBibleAccordionView(testamentType: .old).then {
      $0.configure(title: "구약 성경", subtitle: "39 Books", isClipped: true)
      $0.translatesAutoresizingMaskIntoConstraints = true
      $0.heightAnchor.constraint(equalToConstant: 77).isActive = true
      stackView.addArrangedSubview($0)
    }
  }

  func setClippedNewTestamentOfbibleAccordionView() {
    _=TestamentOfBibleAccordionView(testamentType: .new).then {
      $0.configure(title: "신약 성경", subtitle: "27 Books", isClipped: true)
      $0.translatesAutoresizingMaskIntoConstraints = true
      $0.heightAnchor.constraint(equalToConstant: 77).isActive = true
      
      stackView.addArrangedSubview($0)
    }
  }
  
  func setVerticalChapterVerseWithBlurView() {
    let verse = "\"구하라 그리하면 너희에게 주실 것이요 찾으라 그리하면 찾아낼 것이요 문을 두드리라 그리하면 너희에게 열릴 것이니\""
    _=VerticalChapterVerseWithBlurView().then {
      $0.configure(title: verse, subtitle: "마태복음 7:7")
      stackView.addArrangedSubview($0)
    }
  }
  
  func configHoriCarouselView() {
    let dataSource: [HorizontalVerseCarouselCellItem] = [
      .init(
        backgroundImage: DesignSystemAsset.Image.backgroundImage1.image,
        verse: "\"구하라 그리하면 너희에게 주실 것이요 찾으라 그리하면 찾아낼 것이요 문을 두드리라 그리하면 너희에게 열릴 것이니\"",
        bookName_chapterVerse: "마태복음 7:7"),
      .init(
        backgroundImage: DesignSystemAsset.Image.backgroundImage2.image,
        verse: "\"오직 여호와를 앙망하는 자는 새 힘을 얻으리니 독수리가 날개치며 올라감을 같을 것이요 달음박질하여도 곤비하지 아니하겠고 걸어가도 피곤하지 아니하리로다\"",
        bookName_chapterVerse: "마태복음 7:7"),
      .init(
        backgroundImage: DesignSystemAsset.Image.backgroundImage3.image,
        verse: "\"은을 구하는 것 같이 그것을 구하며 감추어진 보배를 찾는 것 같이 그것을 찾으면 여호와 경외하기를 깨달으며 하나님을 알게 되리니\"",
        bookName_chapterVerse: "잠언 2:4-5")]
    horiCarouselView.configure(dataSource)
  }
  
  func setHorizontalVerseCarouselView() {
    
    horiCarouselView = HorizontalVerseCarouselView(
      cellInsetFromCollectionView: .init(top: 15, left: 16, bottom: 15, right: 16),
      lineSpacing: 10
    ).then {
      $0.translatesAutoresizingMaskIntoConstraints = true
      $0.heightAnchor.constraint(equalToConstant: 220).isActive = true
      $0.widthAnchor.constraint(greaterThanOrEqualToConstant: 300).isActive = true
      stackView.addArrangedSubview($0)
      
      //    horiCarouselView = HorizontalVerseCarouselView(
      //      cellInsetFromCollectionView: .init(top: 15, left: 16, bottom: 15, right: 16),
      //      lineSpacing: 10
      //    ).then {
      //      $0.translatesAutoresizingMaskIntoConstraints = false
      //      view.addSubview($0)
      //      $0.heightAnchor.constraint(equalToConstant: 230).isActive = true
      //      $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
      //      $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
      //      $0.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200).isActive = true
      //    }
    }
  }
  
  func setIconTextTag() {
    let _frame = UIView(frame: .zero)
      .then {
        $0.isUserInteractionEnabled = true
      }
    let oldTestament = IconTextWithClearTag().then {
      $0.configure(icon: .asset(.oldTestamentBook2Small), text: "39 books")
      
    }
    let newTestament = IconTextWithClearTag().then {
      $0.configure(icon: .asset(.newTestamentBook2Small), text: "27 books")
    }
    
    let newTestamentWithClear = IconTextWithClearTag(showClearIcon: true).then {
      $0.configure(icon: .asset(.hambergerMenu), text: "신약")
    }
    
    [oldTestament, newTestament, newTestamentWithClear].forEach(_frame.addSubview(_:))
    NSLayoutConstraint.activate([
      oldTestament.leadingAnchor.constraint(equalTo: _frame.leadingAnchor),
      oldTestament.centerYAnchor.constraint(equalTo: _frame.centerYAnchor),
      newTestament.leadingAnchor.constraint(equalTo: oldTestament.trailingAnchor, constant: 7),
      newTestament.centerYAnchor.constraint(equalTo: _frame.centerYAnchor),
      
      newTestamentWithClear.leadingAnchor.constraint(equalTo: newTestament.trailingAnchor, constant: 7),
      newTestamentWithClear.centerYAnchor.constraint(equalTo: _frame.centerYAnchor)
    ])
    stackView.addArrangedSubview(_frame)
  }
  
  func setTestamentOfBookAccordionView() {
    _=TestamentOfBookAccordionView(testamentType: .old).then {
      $0.configure(title: "스가랴", subtitle: "14 Chapters")
      stackView.addArrangedSubview($0)
    }
    
    _=TestamentOfBookAccordionView(testamentType: .new).then {
      $0.configure(title: "마태복음", subtitle: "28 Chapters")
      stackView.addArrangedSubview($0)
    }
    
    _=TestamentOfBookAccordionView(testamentType: .new).then {
      $0.configure(title: "마태복음", subtitle: "28 Chapters", isClipped: true)
      stackView.addArrangedSubview($0)
    }
  }
  
  func baseComponent_NumerousSHadowContainerView() {
    let nsv = NumerousShadowContainerView(
      contentView: UIView(frame: .zero).then { $0.backgroundColor = .lightGray },
      shadowInfoList: [
        ShadowInfo(color: UIColor(hexCode: "1C99F7"), position: .init(x: 2, y: 1), blur: 4, opacity: 7),
        ShadowInfo(color: .red, position: .init(x: -0.5, y: 0), blur: 4, opacity: 14)
      ])
    let containerView = UIView(frame: .zero).then {
      $0.addSubview(nsv)
      NSLayoutConstraint.activate([
        nsv.centerXAnchor.constraint(equalTo: $0.centerXAnchor),
        nsv.centerYAnchor.constraint(equalTo: $0.centerYAnchor),
        nsv.heightAnchor.constraint(equalToConstant: 35),
        nsv.widthAnchor.constraint(equalToConstant: 35)
      ])
    }
    
    containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    stackView.addArrangedSubview(containerView)
  }
  
  func setExpendedTestamentOfBookAccordionView() {
    expendedTestamentOfBookAccordionView = ExpandedTestamentOfBookAccordionView(isOldTestament: true).then {
      $0.layoutForStackView(from: stackView)
    }
  }
  
  func setSearchedChapterVerseCardView() {
    let searchedChapterVerseCardView1 = SearchedChapterVerseCardView(isOldTestament: false)
    let searchedChapterVerseCardView2 = SearchedChapterVerseCardView(isOldTestament: true)
    stackView.addArrangedSubview(searchedChapterVerseCardView1)
    stackView.addArrangedSubview(searchedChapterVerseCardView2)
    
    searchedChapterVerseCardView1.configure(
      with: .init(reference: .init(book: .init(name: "요한복음") ?? .genesis, chapter: 3, verse: 16),
                  verseContent: "하나님이 세상을 이처럼 사랑하사 독생자를 주셨으니, 이는 그를 믿는 자마다 멸망하지 않고 영생을 얻게 하려 하심이라", isOnHeart: false, highlights: []))
    
    searchedChapterVerseCardView1.configure(
      with: .init(reference: .init(book: .genesis, chapter: 1, verse: 20),
                  verseContent: "하나님이 이르시되 물들은 생물은 번성하여 움직이는 모든 생물을 그 종류대로, 날개있는 모든 새를 그 종류대로 창조하시니 하나님이 보시기에 좋았더라", isOnHeart: false, highlights: []))
  }
  
  func setNormalChapterVerseCardView() {
    let heartBasedOldTestamentView = NormalChapterVerseCardView(addHeartIcon: true)
    let oldTestamentView = NormalChapterVerseCardView(addHeartIcon: false)
    let newTestamentView = NormalChapterVerseCardView(isOldTestament: false, addHeartIcon: false)
    [heartBasedOldTestamentView, oldTestamentView,
     newTestamentView].forEach(stackView.addArrangedSubview(_:))
    heartBasedOldTestamentView.configure(
      withItem: .init(reference: .init(book: .genesis, chapter: 1, verse: 20),
                      verseContent: "하나님이 이르시되 물들은 생물은 번성하여 움직이는 모든 생물을 그 종류대로, 날개있는 모든 새를 그 종류대로 창조하시니 하니님이 보시기에 좋았더라",
                      isOnHeart: false, highlights: []), showPrefixVerseNumber: false)
    oldTestamentView.configure(
      withItem: .init(reference: .init(book: .genesis, chapter: 1, verse: 20),
                      verseContent: "하나님이 이르시되 물들은 생물은 번성하여 움직이는 모든 생물을 그 종류대로, 날개있는 모든 새를 그 종류대로 창조하시니 하니님이 보시기에 좋았더라",
                      isOnHeart: false, highlights: []), showPrefixVerseNumber: false)
    
    newTestamentView.configure(
      withItem: .init(reference: .init(book: .init(name: "요한복음") ?? .genesis, chapter: 3, verse: 16),
                      verseContent: "하나님이 세상을 이처럼 사랑하사 독생자를 주셨으니, 이는 그를 믿는 자마다 멸망하지 않고 영생을 얻게 하려 하심이라",
                      isOnHeart: false, highlights: []), showPrefixVerseNumber: false)
  }
  
  func setSearchedVersesHistoryView() {
    let button = UIButton(frame: .zero).then {
      $0.setTitle("검색 히스토리 컴포넌트 화면 이동", for: .normal)
      $0.setTitleColor(.palette(.title), for: .normal)
      $0.addTarget(self, action: #selector(showHistoryCatalogPage), for: .touchUpInside)
    }
    stackView.addArrangedSubview(button)
  }
  
  func setCheckbox() {
    let checkBox = CheckBox(state: .none)
    let bgView = UIView(frame: .zero).then {
      $0.addSubview(checkBox)
      NSLayoutConstraint.activate([
        checkBox.centerYAnchor.constraint(equalTo: $0.centerYAnchor),
        checkBox.leadingAnchor.constraint(equalTo: $0.leadingAnchor, constant: 10),
        checkBox.widthAnchor.constraint(equalToConstant: 20),
        checkBox.heightAnchor.constraint(equalToConstant: 20)
      ])
    }
    bgView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    stackView.addArrangedSubview(bgView)
  }
  
  func showDailyChallengeView() {
    let button = UIButton(frame: .zero).then {
      $0.setTitle("데일리 챌린지 컴포넌트 화면 이동", for: .normal)
      $0.setTitleColor(.palette(.title), for: .normal)
      $0.addTarget(self, action: #selector(showDailyChallengePage), for: .touchUpInside)
    }
    stackView.addArrangedSubview(button)
  }
  
  func showBibleLabel() {
    let bibleLabel = UILabel(frame: .zero)
    bibleLabel.numberOfLines = 0
    bibleLabel.font = .appleSDGothicNeo(.light, size: 14)
    bibleLabel.configure(
      text: "하니님이 이처럼 세상을 사랑하사 독생자를 주셨으니 누구든지 그를 믿는자는 영생을 얻으리로다", highlights: [
        .init(id: .init(), range: .init(location: 3, length: 3), colorIndex: .blue),
        .init(id: .init(), range: .init(location: 7, length: 3), colorIndex: .green)],
      note: .init(noteId: 1, range: .init(location: 2, length: 5), text: "뀨???"))
    stackView.addArrangedSubview(bibleLabel)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
      bibleLabel.font = .appleSDGothicNeo(.light, size: 14)
    })
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 6, execute: {
      bibleLabel.font = .appleSDGothicNeo(.light, size: 20)
    })
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 9, execute: {
      bibleLabel.font = .appleSDGothicNeo(.light, size: 30)
    })
  }
  
//  func setLampView() {
//    let bgView = UIView(frame: .zero)
////    let lampView = LampView().setAutoLayout()
//    bgView.addSubview(lampView)
//    NSLayoutConstraint.activate([
//      lampView.topAnchor.constraint(equalTo: bgView.topAnchor),
//      lampView.centerXAnchor.constraint(equalTo: bgView.centerXAnchor),
//      lampView.widthAnchor.constraint(equalToConstant: 120),
//      lampView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor)
//    ])
//    bgView.heightAnchor.constraint(equalToConstant: 400).isActive = true
//    stackView.addArrangedSubview(bgView)
//  }
}

// MARK: - Action
extension ViewController {
  @objc func showHistoryCatalogPage() {
    let historyCatalogViewController = HistoryCatalogViewController()
    navigationController?.pushViewController(historyCatalogViewController, animated: true)
  }
  
  @objc func showDailyChallengePage() {
    let vc = DailyChallengeViewController()
    navigationController?.pushViewController(vc, animated: true)
  }
}

// MARK: - LayoutSupportable
extension ViewController: LayoutSupportable {
  func layoutUI() {
    view.addSubview(scrollView)
    scrollView.addSubview(stackView)
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      
      stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
    ])
  }
}
