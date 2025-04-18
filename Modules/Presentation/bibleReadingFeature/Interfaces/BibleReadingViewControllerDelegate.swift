//
// BibleReadingViewControllerDelegate.swift
//  BibleReadingFeature
//
//  Created by 양승현 on 3/25/25.
//

import Foundation

public protocol BibleReadingViewControllerDelegate: AnyObject {
  func handlePrevPageShowing(_ bySleepTimer: Bool)
  
  func handleNextPageShowing(_ bySleepTimer: Bool)
  
  func provideNavigationTitle(_ title: String)
  
  func willDisplayTitleHeaderView(_ title: String?)
  
  func disappearTitleHeaderView()
  
  func hideNavigationMenuItem()
  
  func showNavigationMenuItem()
}
