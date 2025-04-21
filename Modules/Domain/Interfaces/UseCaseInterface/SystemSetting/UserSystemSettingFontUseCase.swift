//
//  UserSystemSettingFontUseCase.swift
//  Domain
//
//  Created by 양승현 on 3/12/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public protocol UserSystemSettingFontUseCase {
  func updateFontSize(_ fontSize: CGFloat)
  
  func fetchFontSize() -> CGFloat
}
