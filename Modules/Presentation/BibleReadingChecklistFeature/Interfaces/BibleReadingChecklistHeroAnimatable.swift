//
//  File.swift
//  BibleReadingChecklistInterface
//
//  Created by 양승현 on 3/27/25.
//

import Foundation

public protocol BibleReadingChecklistHeroAnimatable {
  /// 화면 전환이 되는 대상은, 그 보여질 데이터들을 미리 받아놔야함 ㅇㅅㅇ. 그래야 애니메이션이 자연스러워짐.
  /// 호출하는 Animator는 transitionContext.viewController(forKey: .to)인 viewController가 이 프로토콜을 채택한다면,
  /// toVC가 되는거!
  var initialLoadingCompletionHandler: (() -> Void)? { get set }
  
  /// 트랜지션 애니메이션을 다 진행한 후에 잔잔하게 그라디언트 깔아주기
  func shouldShowGradient()
}
