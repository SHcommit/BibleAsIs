//
//  BibleReadingChekclistFlowDependencies.swift
//  BibleReadingChecklistInterface
//
//  Created by 양승현 on 3/27/25.
//

import UIKit

public protocol BibleReadingChekclistFlowDependencies {
  /// - Parameters dismissCompletionHandler : dismiss animation 커스텀할 때 활용함.
  /// 델리게이트로
  ///   커스텀 트랜지션 애니메이션을 진행하는게 깔끔함 ㅇㅅㅇ
  func makeViewController(dismissCompletionHandler: (() -> Void)?) -> UIViewController
  
  func showDatePickerAlert(_ alert: UIAlertController)
  
  func dismissWhenBackTap(completion: (() -> Void)?)
}
