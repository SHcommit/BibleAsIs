//
//  OwnerLastLoginDateRepository.swift
//  DomainEntity
//
//  Created by 양승현 on 3/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol OwnerLastLoginDateRepository {
  
  /// 오늘 접속한 날짜 정보를 저장함
  func saveTodayAsLastLogin(with todayEntity: LastLoginDateEntity)
  
  /// 최근에 들어왔을때 날짜를 불러옴
  func fetchLastLoginDate() -> LastLoginDateEntity?
}
