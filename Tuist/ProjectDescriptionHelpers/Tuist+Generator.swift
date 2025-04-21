//
//  Target+Generatable.swift
//  ProjectDescriptionHelpers
//
//  Created by 양승현 on 2025/01/17.
//

import ProjectDescription

extension Project {
  // MARK: - Constants
  public static let bundleId = "com.BibleAsIs"
  /// minimum deployment target
  public static let iosVersion = "13.0"
  
  // MARK: - Helpers
  public static func projectForModule(
    name: String,
    targets: [Target] = [],
    additionalFiles: [FileElement] = [],
    schemes: [Scheme] = []
  ) -> Project {
    return Project(
      name: name,
      organizationName: "seunghyun yang",
      options: .options(
        textSettings: .textSettings(indentWidth: 2, tabWidth: 2, wrapsLines: true)
      ),
      settings: .currentEnvironmentSettingsForFramework,
      targets: targets,
      schemes: schemes,
      additionalFiles: additionalFiles
    )
  }
  
  public static func projectForApp(
    name: String,
    targets: [Target] = [],
    additionalFiles: [FileElement] = [],
    schemes: [Scheme] = []
  ) -> Project {
    return Project(
      name: name,
      organizationName: "seunghyun yang",
      options: .options(
        textSettings: .textSettings(indentWidth: 2, tabWidth: 2, wrapsLines: true)
      ),
      settings: .currentEnvironmentSettingsForApp,
      targets: targets,
      schemes: schemes,
      additionalFiles: additionalFiles
    )
  }
}

/// Feature 타겟 이외에 Interface타겟이나 데모타겟 같은거에 swiftlint걸면 Feature에서 발생되는
///   swiftlint경고가 이제 Interface에는 없는데 같이 경고 내줌.
///   따따블로 이제 Issue navigator에 보여지는거지..
extension Target {
  public static func target(
    name: String,
    product: Product,
    bundleId: String? = nil,
    infoPlist: InfoPlist? = .default,
    sources: SourceFilesList? = nil,
    resources: ResourceFileElements? = nil,
    entitlements: Entitlements? = nil,
    scripts: [TargetScript] = [],
    dependencies: [TargetDependency] = [],
    settings: Settings? = nil
//    settings: Settings? = .currentEnvironmentSettingsForFramework
  ) -> Self {
    Self.target(
      name: name,
      destinations: .init([.iPhone]),
      product: product,
      bundleId: bundleId ?? Project.bundleId + "." + name.lowercased(),
      deploymentTargets: .iOS(Project.iosVersion),
      infoPlist: infoPlist,
      sources: sources,
      resources: resources,
      entitlements: entitlements,
      scripts: scripts,
      dependencies: dependencies,
      settings: settings
    )
  }
  
  public static func interfaceTarget(
    module: Module,
    product: Product = .staticFramework,
    bundleId: String? = nil,
    infoPlist: InfoPlist? = .default,
    sources: SourceFilesList? = .interfaces,
    resources: ResourceFileElements? = nil,
    entitlements: Entitlements? = nil,
    scripts: [TargetScript] = [],
    dependencies: [TargetDependency] = [],
//    settings: Settings? = .currentEnvironmentSettingsForFramework
    settings: Settings? = nil
  ) -> Self {
    .target(
      name: module.interfaceName,
      product: product,
      bundleId: bundleId,
      infoPlist: infoPlist,
      sources: .interfaces,
      resources: resources,
      entitlements: entitlements,
      scripts: scripts,
      dependencies: dependencies,
      settings: settings)
  }
  
  public static func unitTestsTarget(
    module: Module,
    bundleId: String? = nil,
    infoPlist: InfoPlist? = .default,
    resources: ResourceFileElements? = nil,
    entitlements: Entitlements? = nil,
    scripts: [TargetScript] = [],
    dependencies: [TargetDependency] = [],
    settings: Settings? = nil
//    settings: Settings? = .currentEnvironmentSettingsForFramework
  ) -> Self {
    .target(
      name: module.testName,
      product: .unitTests,
      bundleId: bundleId,
      infoPlist: infoPlist,
      sources: .tests,
      resources: resources,
      entitlements: entitlements,
      scripts: scripts,
      dependencies: dependencies.isEmpty ? [.target(name: module.name)] : dependencies,
      settings: settings)
  }
  
  /// 모듈 이름 + 추가적인 이름으로 타겟 생성
  public static func target(
    module: Module,
    additionalTargetName: String? = nil,
    product: Product = .staticFramework,
    bundleId: String? = nil,
    infoPlist: InfoPlist? = .default,
    sources: SourceFilesList? = .sources,
    resources: ResourceFileElements? = nil,
    entitlements: Entitlements? = nil,
    scripts: [TargetScript] = [.swiftLint],
    dependencies: [TargetDependency] = [],
    settings: Settings? = nil
//    settings: Settings? = .currentEnvironmentSettingsForFramework
  ) -> Self {
    .target(
      name: module.name + (additionalTargetName ?? ""),
      product: product,
      bundleId: bundleId,
      infoPlist: infoPlist,
      sources: sources,
      resources: resources,
      entitlements: entitlements,
      scripts: scripts,
      dependencies: dependencies,
      settings: settings)
  }
  
  // MARK: - demo
  public static func demoTarget(
    feature: Module.Feature,
    infoPlist: InfoPlist? = nil,
    sources: SourceFilesList? = nil,
    resources: ResourceFileElements? = nil,
    scripts: [TargetScript] = [.swiftLint],
    dependencies: [TargetDependency],
    settings: Settings? = nil
//    settings: Settings? = .currentEnvironmentSettingsForApp
  ) -> Self {
    Target.target(
      name: "BibleAsIs\(feature.name)DemoApp",
      destinations: Destinations([.iPhone]),
      product: .app,
      bundleId: "\(Project.bundleId).\(feature.name.lowercased())DemoApp",
      deploymentTargets: .iOS(Project.iosVersion),
      infoPlist: infoPlist == nil ? .demo : infoPlist,
      sources: sources == nil ? .forDemo("Support") : sources,
      scripts: scripts.isEmpty ? [.swiftLint] : scripts,
      dependencies: dependencies,
      settings: settings)
  }
}
