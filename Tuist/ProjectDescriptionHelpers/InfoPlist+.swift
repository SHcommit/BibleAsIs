//
//  InfoPlist+.swift
//  ProjectDescriptionHelpers
//
//  Created by 양승현 on 2025/01/17.
//

import ProjectDescription

extension InfoPlist {
  /// DEBUG-RELEASE 공통
  public static let app: Self = .file(path: .relativeToRoot("Config/Info.plist"))
  public static let designSystem: Self = .file(path: .relativeToRoot("Config/DesignSystem-Info.plist"))
  public static let demo: Self = .file(path: .relativeToRoot("Config/Demo-Info.plist"))
}
