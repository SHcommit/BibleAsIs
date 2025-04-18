//
//  BibleFeedCoordinator.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 3/28/25.
//

import UIKit
import Common
import Swinject
import MessageUI
import AcknowList
import DesignSystem
import DomainEntity
import DesignSystemItems
import BibleFeedInterface
import BibleReadingInterface
import BibleNoteHomeInterface
import BibleHeartHistoryInterface
import BibleMccCheyneChallengeInterface
import BibleReadingChecklistInterface

/// NSObjectProtocol 타입의 델리게이트 준수해야해서 struct -> class로 변경
final class BibleFeedCoordinator: NSObject, BibleFeedFlowDependencies, FlowCoordinatable {
  // MARK: - Properties
  var navigationController: UINavigationController?
  
  var resolver: any Swinject.Resolver
  
  // MARK: - Lifecycle
  init(navigationController: UINavigationController? = nil, resolver: any Swinject.Resolver) {
    self.navigationController = navigationController
    self.resolver = resolver
  }
  
  // MARK: - Helpers
  func makeViewController() -> UIViewController {
    guard
      let feedViewController = resolver.resolve(
        UIViewController.self,
        name: BibleFeedViewController._identifier,
        argument: self)
    else { fatalError(.registrationErrorMsgByInner(BibleFeedViewController.self)) }
    return feedViewController
  }
  
  func makeMccCheynechallengeViewController() -> UIViewController {
    guard let mccCheyneChallengeGateway = resolver.resolve(BibleMccCheyneChallengeInterface.self) else {
      fatalError(.registrationErrorMsgByUnknownOuter(type: BibleMccCheyneChallengeInterface.self))
    }
    return mccCheyneChallengeGateway.makeSettingModule(
      navigationController: navigationController,
      resolver: resolver)
  }
  
  func showBibleReadingChecklistPage() {
    guard let readingChecklistGateway = resolver.resolve(BibleReadingChecklistInterface.self) else {
      fatalError(.registrationErrorMsgByUnknownOuter(type: BibleReadingChecklistInterface.self))
    }
    let readingChecklistModule = readingChecklistGateway.makeBibleReadingChecklistModule(
      navigationController: navigationController,
      resolver: resolver,
      dismissCompletionHandler: nil)
    navigationController?.pushViewController(readingChecklistModule, animated: true)
  }

  func showBibleHeartHistoryPage() {
    guard let bibleHeartHistoryGateway = resolver.resolve(BibleHeartHistoryInterface.self) else {
      fatalError(.registrationErrorMsgByUnknownOuter(type: BibleHeartHistoryInterface.self))
    }
    let heartHistoryViewController = bibleHeartHistoryGateway.makeBibleHeartHistoryModule(
      navigationController: navigationController,
      resolver: resolver,
      forPageViewMode: false)
    
    navigationController?.pushViewController(heartHistoryViewController, animated: true)
  }
  
  /// - Parameters entryWithNote, andEntryVerseForNote : 헤더를 누를 경우 두 변수는 nil, Specific note를 누를 경우 두 매개변수에 의해 특정한 노트 화면으로 이동 가능
  func showBibleNoteHomePage(entryWithNote: BibleNote?, andEntryVerseforNote: BibleVerse?) {
    guard let bibleNoteHomeGateway = resolver.resolve(BibleNoteHomeInterface.self) else {
      fatalError(.registrationErrorMsgByUnknownOuter(type: BibleNoteHomeInterface.self))
    }
    let bibleNoteHomeViewController = bibleNoteHomeGateway.makeBibleNoteHomeModule(
      navigationController: navigationController,
      resolver: resolver,
      forPageViewMode: false,
      entryWithNote: entryWithNote,
      andVerseForNote: andEntryVerseforNote)
    
    bibleNoteHomeViewController.navigationController?.navigationItem.title = "성경 노트"
    navigationController?.pushViewController(bibleNoteHomeViewController, animated: true)
  }
  
  func showBibleReadingPageForRecentReadVerses(with bookclipItem: RecentReadBibleBookclipItem) {
    guard let bibleReadingGateway = resolver.resolve(bibleReadingInterface.self) else {
      fatalError(.registrationErrorMsgByUnknownOuter(type: RecentReadBibleBookclipItem.self))
    }
    
    let recentBibleReadingEntryItem = BibleReadingEntryItem(
      bibleBook: bookclipItem.bibleReference.book,
      chapter: bookclipItem.bibleReference.chapter)
    
      let bibleReadingViewController = bibleReadingGateway.makeBibleContentPaginationModule(
      navigationController: navigationController,
      resolver: resolver,
      currentReadingEntryItem: recentBibleReadingEntryItem,
      bibleReadingEntryItemsForRange: [recentBibleReadingEntryItem],
      isRestrictEntry: false)
    bibleReadingViewController.hidesBottomBarWhenPushed = true
    
    navigationController?.pushViewController(bibleReadingViewController, animated: true)
  }
  
  func showBibleGardenYearSelectionPage(withUserSelectionYear currentYear: Int, completion: @escaping (Int) -> Void) {
    let alert = UIAlertController(title: "🗓️ 연도를 선택하세요", message: nil, preferredStyle: .actionSheet)
    
    let pickerViewController = UIViewController()
    pickerViewController.preferredContentSize = CGSize(width: 290, height: 220)
    
    let yearPickerVC = YearPickerViewController(initialYearState: currentYear)
    yearPickerVC.onYearPicked = completion
    
    if let yearPickerView = yearPickerVC.view {
      yearPickerView.setAutoLayout()
      pickerViewController.view.addSubview(yearPickerView)
      NSLayoutConstraint.activate([
        yearPickerView.centerYAnchor.constraint(equalTo: pickerViewController.view.centerYAnchor),
        yearPickerView.centerXAnchor.constraint(equalTo: pickerViewController.view.centerXAnchor),
        yearPickerView.widthAnchor.constraint(equalToConstant: 250),
        yearPickerView.heightAnchor.constraint(equalToConstant: 150)
      ])
    } else {
      ToastController.shared.showToast(
        message: "시스템 오류가 발생되 연도 선택이 불가능합니다.\n잠시 후에 다시 시도해주세요.",
        position: .navBarBottom,
        type: .success)
      return
    }
    
    alert.setValue(pickerViewController, forKey: "contentViewController")
    
    let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
      completion(yearPickerVC.selectedYear)
    }
    let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    alert.addAction(confirmAction)
    alert.addAction(cancelAction)
    
    navigationController?.present(alert, animated: true)
  }
  
  func showFeedSettingPage() {
    guard let feedSettingPage = resolver.resolve(
      UIViewController.self,
      name: FeedSettingViewController._identifier,
      argument: self
    ) else { return }
    navigationController?.pushViewController(feedSettingPage, animated: true)
  }
}

// MARK: - FeedSettingFlowDependencies
extension BibleFeedCoordinator: FeedSettingFlowDependencies {
  func showQnAMailPage() {
    guard MFMailComposeViewController.canSendMail() else {
      showAlertForFailureToOpenMessage()
      return
    }
    
    let mail = MFMailComposeViewController()
    mail.mailComposeDelegate = self
    mail.setSubject("iOS 개발팀에게 문의 및 개선사항을 남겨주세요.")
    mail.setToRecipients(["journeyoffaiths2025@gmail.com"])
    mail.setMessageBody(defaultMeessage, isHTML: true)
    navigationController?.present(mail, animated: true)
  }
  
  func showOpenSourcesPage() {
    #if DEBUG
    if let resourceURLs = try? FileManager.default.contentsOfDirectory(at: Bundle.module.bundleURL, includingPropertiesForKeys: nil) {
      resourceURLs.forEach { print("뀨? \($0.lastPathComponent)") }
    }
    #endif
    
    guard
      let url = Bundle.module.url(forResource: "Package", withExtension: "resolved"),
      let data = try? Data(contentsOf: url),
      let acknowList = try? AcknowPackageDecoder().decode(from: data)
    else { return }
    let _acknows = acknowList.acknowledgements.map {
      _Acknow(title: $0.title, text: $0.text ?? "", license: $0.license)
    }
    let acknowledgementsViewController = AcknowledgementsViewController(acknowledgements: _acknows)
    navigationController?.pushViewController(acknowledgementsViewController, animated: true)
  }
  
  func showCreditsPage() {
    navigationController?.pushViewController(FeedCreditsViewController(), animated: true)
  }
  
}

// MARK: - Helpers
extension BibleFeedCoordinator {
  fileprivate var appVersion: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
  }
  
  fileprivate var buildNumber: String {
    Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
  }
  
  fileprivate var defaultMeessage: String {
    """
    <p style="font-family: Arial, sans-serif; color: #333; background-color: #f0f0f0; 
    padding: 20px; margin: 0; white-space: pre-wrap;">
    안녕하세요. "<span style="font-weight: bold; color: #FBD632;">성경대로"</span> iOS 개발 담당 양승현 입니다.
    <br>
    - 문의사항이나 버그, 개선사항 등은 아래에 작성해주세요.
    - 개역한글판 성경 오타나 성경 본문 중 일치하지 않는 내용이 있다면 작성해주세요.
    - 이용해주셔서 정말 감사합니다.
    
    
    ⭐ 문의 관련 스크린샷을 첨부하시면 더욱 빠른 확인이 가능합니다.
    <br><br>
    -------------------
    <span style="font-weight: bold; color: #3366cc;">Device Model : \(UIDevice.current.model)</span><br>
    <span style="font-weight: bold; color: #3366cc;">Device OS :  \(UIDevice.current.systemName)</span><br>
    <span style="font-weight: bold; color: #3366cc;">Device version :  \(UIDevice.current.systemVersion)</span><br>
    <span style="font-weight: bold; color: #3366cc;">App Version : \(buildNumber)</span><br>
    -------------------
    </p>
    """
  }
  
  fileprivate func showAlertForFailureToOpenMessage() {
    let alert = UIAlertController(
      title: "메일 전송 실패",
      message: "메일을 보내려면 'Mail' 앱이 필요합니다. App Store에서 해당 앱을 복원하거나 이메일 설정을 확인하고 다시 시도해주세요.",
      preferredStyle: .alert)
    let gotoAppStore = UIAlertAction(title: "App Store로 이동하기", style: .default) { _ in
      guard
        let url = URL(string: "https://apps.apple.com/kr/app/mail/id1108187098"),
        UIApplication.shared.canOpenURL(url)
      else { return }
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    let cancel = UIAlertAction(title: "취소", style: .destructive, handler: nil)
    [gotoAppStore, cancel].forEach { alert.addAction($0) }
    
    navigationController?.present(alert, animated: true)
  }
}

// MARK: - MFMailComposeViewControllerDelegate
extension BibleFeedCoordinator: MFMailComposeViewControllerDelegate {
  func mailComposeController(
    _ controller: MFMailComposeViewController,
    didFinishWith result: MFMailComposeResult,
    error: Error?
  ) {
    navigationController?.dismiss(animated: true, completion: nil)
    if result == .sent {
      ToastController.shared.showToast(message: "메일이 성공적으로 전송됬습니다.", type: .error)
    }
  }
}
