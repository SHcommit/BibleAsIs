//
//  Environment+Helpers.swift
//  ProjectDescriptionHelpers
//
//  Created by 양승현 on 4/9/25.
//

import Foundation
import ProjectDescription

/// - Note 1: Use build target like THIS!!
///
/// ```
/// export TUIST_BUILD_TARGET=PRD
/// echo $TUIST_BUILD_TARGET
/// 이렇게 해서 PRD인지 DEV인지 확인하고
///
/// tuist generate 하자!
/// 이거 좀 바뀜,,
/// -> make generateDEV or generatePRD
/// /// ```
public enum BuildTarget: String {
  case dev = "DEV"
  case prd = "PRD"
  
  public init?(rawValue: String) {
    switch rawValue {
    case "DEV":
      self = .dev
    default:
      self = .prd
    }
  }
  
  public var configurationName: ConfigurationName {
    return ConfigurationName.configuration(self.rawValue)
  }
  
  /// .env에서 변경 가능 TUIST_BUILD_TARGET
  public static func currentEnvironment() -> Self {
    if let value = ProcessInfo.processInfo.environment["TUIST_BUILD_TARGET"],
       let target = BuildTarget(rawValue: value) {
      return target
    }
    return .dev
  }
}

extension ProjectDescription.Configuration {
  public static var debug: Self {
    .debug(name: .debug)
  }
  
  public static var release: Self {
    .debug(name: .release)
  }
  
//  public static var dev: Self {
//    Self.debug(name: "DEV", settings: [:])
//  }
//  
//  public static var prd: Self {
//    .release(name: "PRD", settings: [:])
//  }
}

enum Environment {
  public static var rootDir: String {
    let filePath = #file
    let fileURL = URL(fileURLWithPath: filePath)
    let rootURL = fileURL
      .deletingLastPathComponent() // ProjectDescriptionHelpers
      .deletingLastPathComponent() // Tuist
      .deletingLastPathComponent() // 나야나!! 내가 바로 루트
    return rootURL.path
  }
}
