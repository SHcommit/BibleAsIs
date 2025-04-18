//
//  SceneDelegate+Notifications.swift
//  JourneyOfFaithApp
//
//  Created by 양승현 on 4/10/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import UIKit
import UserNotifications

extension SceneDelegate {
  // TODO: - 출시 이후에 랜덤벌스 이거 해보자 ui 또 만들어야함 https://www.google.com/search?sca_esv=4f5a3464f54e4b81&rlz=1C5GCEA_enKR986KR987&q=daily+verse+notification&udm=2&fbs=ABzOT_CZsxZeNKUEEOfuRMhc2yCI6hbTw9MNVwGCzBkHjFwaKzX-IKePrWKWeOe-jIQvpgxNos-rYkZjCE31ffi49IJ79i7rmDJSqcWaRWN2tak-tYDwZho6XP2nBcx5-FZONQLEQbnvmvetVXTPjRuIDppe9H1I4mozaR2GY3oundwlz_cG0l94oWH4tbgPJtJZJ1YpJnSh9CI66kY42PiDpQK0yyXn9g&sa=X&ved=2ahUKEwiDgvHF6cyMAxVdafUHHQWVNjQQtKgLegQIFRAB&biw=1720&bih=1294&dpr=1#vhid=PvA7RK1hOMCRFM&vssid=mosaic
  func requestNotificationPermission() {
    
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      if settings.authorizationStatus == .notDetermined {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
          if granted {
            print("알림 권한 허용~~")
          } else {
            print("알림 권한 거부됨")
          }
        }

      } else {
        print("지금 알림 권한 상태: \(settings.authorizationStatus.rawValue)")
      }
    }
  }
}
