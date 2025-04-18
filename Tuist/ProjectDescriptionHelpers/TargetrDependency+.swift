//
//  TargetrDependency+.swift
//  ProjectDescriptionHelpers
//
//  Created by 양승현 on 2025/01/17.
//

import ProjectDescription

// MARK: - Helpers
extension TargetDependency {
  /// 타겟은 Proejct 내부에서: )
  public static func interfaceTarget(module: Module) -> Self {
    .target(name: module.interfaceName)
  }
  
  public static func target(module:Module, additionalName: String = "") -> Self {
    .target(name: module.name + additionalName)
  }
  
  /// 외부에서 타겟 접근
  public static func project(module: Module, forInterface: Bool) -> Self {
    if forInterface {
      return .project(target: module.interfaceName, path: module.path)
    }
    return .project(target: module.name, path: module.path)
  }
  
  public static func project(module: Module, additionalTargetName: String = "") -> Self {
    .project(target: module.name + additionalTargetName, path: module.path)
  }
}
