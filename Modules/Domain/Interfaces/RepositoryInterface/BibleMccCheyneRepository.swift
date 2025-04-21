//
//  BibleMccCheyneRepository.swift
//  DomainEntity
//
//  Created by 양승현 on 2/26/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol BibleMccCheyneRepository {
  var numberOfRecords: Int { get }
  
  /// 실패시 옵셔널 반환
  func fetchDailyReadingPlan(
    forDay: Int,
    completion: @escaping (Result<DailyMccCheyneEntity?, Error>) -> Void
  )
  
  /// 읽음 1 안읽음 0 으로 표시해야 함! ( 디비에 저장할땐 1 = true / 0 = false )
  func updateDailyReadingPlan(
    forDay: Int,
    entry: DailyMccCheyneEntity,
    completion: @escaping (Result<Bool, Error>) -> Void
  )
}
