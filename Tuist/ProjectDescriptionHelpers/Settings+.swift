//
//  Settings+.swift
//  ProjectDescriptionHelpers
//
//  Created by 양승현 on 2/20/25.
//

import ProjectDescription

/// 조심해야 할 것은 프레임워크는 AppIcon. 필요없음
extension Settings {
  public static var currentEnvironmentSettingsForFramework: Settings {
    return BuildTarget.currentEnvironment() == .prd ? .prdFrameworkSettings : .devFrameworkSettings
  }
  
  public static var currentEnvironmentSettingsForApp: Settings {
    return BuildTarget.currentEnvironment() == .prd ? .prdAppSettings : .devAppSettings
  }
  
  private static let baseSettings: [String: SettingValue] = [
    /// 이거는 이제 그 xcode 15부터 나오는 Update to recommended settings 경고
    "ENABLE_ASSETCATALOG_SYMBOL_GENERATION": "NO",
    "ENABLE_USER_SCRIPT_SANDBOXING": "NO",
    "ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOL_EXTENSIONS": "NO",
    "IPHONEOS_DEPLOYMENT_TARGET": "\(Project.iosVersion)",
    "DEVELOPMENT_TEAM": "4GW2K8FK25",
    "CODE_SIGN_STYLE": "Manual"
  ]
  
  // MARK: for DEV
  /// for framework
  private static let baseDevSettings: [String: SettingValue] = [
    "OTHER_SWIFT_FLAGS": ["-Onone", "-DDEBUG"],
    "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
    
    "CODE_SIGN_IDENTITY": "Apple Development",
    "PROVISIONING_PROFILE_SPECIFIER": "com.BibleAsIs-Debug",
//    "PROVISIONING_PROFILE": "\(Environment.rootDir)/Signing/com.BibleAsIs-Debug"
  ]
  
  /// forApp
  private static let _devAppSettings: [String: SettingValue] = baseDevSettings.merging([
    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon"
  ])
  
  // MARK: for PRD
  /// for framework
  private static let basePrdSettings: [String: SettingValue] = [
    /// 이거 해야 #if RELEASE  .. .#endif 이거  로직 내부 코드들 동작됨
    "OTHER_SWIFT_FLAGS": ["-DRELEASE"],
    "OTHER_LDFLAGS":["-all_load -Objc"],
    
    // 파베 carshlytics
    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
    "GCC_GENERATE_DEBUGGING_SYMBOLS": "YES",
    
    "CODE_SIGN_IDENTITY": "Apple Distribution",
//    "PROVISIONING_PROFILE": "\(Environment.rootDir)/Signing/com.BibleAsIs-Release"
    "PROVISIONING_PROFILE_SPECIFIER": "com.BibleAsIs-Release"
  ]
  
  /// for app
  private static let _prdAppSettings: [String: SettingValue] = basePrdSettings.merging([
    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
  ])
  
  public static let devFrameworkSettings: Self = .settings(
    base: baseSettings.merging(baseDevSettings),
    defaultSettings: .recommended)
  
  public static let devAppSettings: Self = .settings(
    base: baseSettings.merging(_devAppSettings),
    defaultSettings: .recommended)
  
  public static let prdFrameworkSettings: Self = .settings(
    base: baseSettings.merging(basePrdSettings),
    defaultSettings: .recommended
  )
  
  public static let prdAppSettings: Self = .settings(
    base: baseSettings.merging(_prdAppSettings),
    defaultSettings: .recommended
  )
}
