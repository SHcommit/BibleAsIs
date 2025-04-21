//
//  OwnerBibleMccCheyneRepository.swift
//  DomainInterface
//
//  Created by 양승현 on 2/26/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity

public protocol OwnerBibleMccCheyneRepository {
  func fetchCurrentChallengeDay(completion: @escaping (Result<RecentMccCheyneDay, Error>) -> Void)
  func updateCurrentChallengeDay(_ day: Int, completion: @escaping (Result<Void, Error>) -> Void)
}
