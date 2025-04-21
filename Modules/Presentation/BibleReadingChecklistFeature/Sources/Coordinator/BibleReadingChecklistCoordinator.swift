//
//  BibleReadingChecklistCoordinator.swift
//  BibleReadingChecklistFeature
//
//  Created by 양승현 on 3/27/25.
//

import UIKit
import Common
import Swinject
import BibleReadingChecklistInterface

struct BibleReadingChecklistCoordinator: BibleReadingChekclistFlowDependencies, FlowCoordinatable {
  
  weak var navigationController: UINavigationController?
  
  var resolver: Swinject.Resolver
  
  init(navigationController: UINavigationController? = nil, resolver: Swinject.Resolver) {
    self.navigationController = navigationController
    self.resolver = resolver
  }
  
  func makeViewController(
    dismissCompletionHandler: (() -> Void)?
  ) -> UIViewController {
    guard let readingChecklistViewController = resolver.resolve(
      UIViewController.self,
      name: BibleReadingChecklistViewController._identifier,
      arguments: self, dismissCompletionHandler
    ) else { fatalError(.registrationErrorMsgByInner(BibleReadingChecklistViewController.self)) }
    return readingChecklistViewController
  }
  
  func showDatePickerAlert(_ alert: UIAlertController) {
    navigationController?.present(alert, animated: true)
  }
  
  func dismissWhenBackTap(completion: (() -> Void)?) {
//    navigationController?.dismiss(animated: true, completion: completion)
    navigationController?.popViewController(animated: true)
    completion?()
  }
}
