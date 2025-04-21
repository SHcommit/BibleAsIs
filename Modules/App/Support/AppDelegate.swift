//
//  AppDelegate.swift
//  JourneyOfFaithApp
//
//  Created by 양승현 on 1/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit

#if RELEASE
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
#if RELEASE
    let userDefaults = UserDefaults.standard
    FirebaseApp.configure()
    let crashUserIdKey = "crashUserId"
    
    if userDefaults.string(forKey: crashUserIdKey) == nil {
      userDefaults.set(UUID().uuidString, forKey: crashUserIdKey)
    }
    
    if let userId = userDefaults.string(forKey: crashUserIdKey) {
      Crashlytics.crashlytics().setUserID(userId)
    }
#endif
    return true
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
  }
  
  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    // Cald when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
}
