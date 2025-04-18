//
//  DefaultOwnerLastLoginDateUseCase.swift
//  Domain
//
//  Created by 양승현 on 3/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import DomainInterface

public final class DefaultOwnerLastLoginDateUseCase: OwnerLastLoginDateUseCase {
  // MARK: - Dependencies
  private let calendar = Calendar(identifier: .gregorian)
  
  private let ownerLastLoginDateRepository: OwnerLastLoginDateRepository
  
  // MARK: - Lifecycle
  public init(ownerLastLoginDateRepository: OwnerLastLoginDateRepository) {
    self.ownerLastLoginDateRepository = ownerLastLoginDateRepository
  }
  
  // MARK: - Helpers
  public func saveTodayAsLastLogin() {
    let today = getTodayComponents()
    /// nil일  수 없음
    if today.year == nil || today.month == nil || today.day == nil {
      assertionFailure("안될수가 없는건데? 분명 값이 들어와야 하는데")
    }
    let entity = LastLoginDateEntity(year: today.year ?? 2025, month: today.month ?? 3, day: today.day ?? 19)
    ownerLastLoginDateRepository.saveTodayAsLastLogin(with: entity)
  }
  
  public func fetchLastLoginDate() -> LastLoginDateEntity? {
    ownerLastLoginDateRepository.fetchLastLoginDate()
  }
  
  /// 기록이 없는 처음의 경우 새로운 날짜로 생각하자
  public func isNewDay() -> Bool {
    guard let lastLogin = ownerLastLoginDateRepository.fetchLastLoginDate() else {
      return true
    }
    let today = getTodayComponents()
    return !(lastLogin.year == today.year && lastLogin.month == today.month && lastLogin.day == today.day)
  }
  
  // 오늘의 Day Index 반환 오늘의 날짜 (년월일)을 이제 (1~365) 중 하나로 반환 .이때 윤년 고려 안함
  public func getTodayDayIndex() -> Int {
    return currentTodayIndex()
  }
  
  private func getTodayComponents() -> DateComponents {
    return calendar.dateComponents([.year, .month, .day], from: Date())
  }
  
  /// 오늘의 년월일을 1에서 365일 중 하나로 윤년은 처리 안함
  private func currentTodayIndex() -> Int {
    let todayComponents = getTodayComponents()
    return toDayIndex(from: todayComponents)
  }
  
  /// 년월일을 1에서 365일 중 하나로 윤년은 처리 안함
  private func toDayIndex(from dateComponents: DateComponents) -> Int {
    guard
      let year = dateComponents.year,
      let month = dateComponents.month,
      let day = dateComponents.day,
      let date = calendar.date(from: DateComponents(year: year, month: month, day: day))
    else {
      return 1
    }
    
    return calendar.ordinality(of: .day, in: .year, for: date) ?? 1
  }
}
