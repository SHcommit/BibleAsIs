//
//  ModuleName.swift
//  ProjectDescriptionHelpers
//
//  Created by 양승현 on 2025/01/17.
//

import ProjectDescription

public enum Module: RawRepresentable, CaseIterable {
  public typealias RawValue = String
  
  case app
  case catalog
  
  // MARK: - Presentation
  public enum Feature: String, CaseIterable {
    case bibleHomeFeature = "BibleHomeFeature"
    case bibleReadingFeature = "BibleReadingFeature"
    
    // MARK: - Activities
    case myActivityFeature = "MyActivityFeature"
    
    case bibleNoteHomeFeature = "BibleNoteHomeFeature"
    
    case bibleNoteFeature = "BibleNoteFeature"
    
    case bibleHighlightFeature = "BibleHighlightFeature"
    
    case bibleHeartHistoryFeature = "BibleHeartHistoryFeature"
    
    case bibleReadingChecklistFeature = "BibleReadingChecklistFeature"
    
    // MARK: - 뀨
    case bibleSearchFeature = "BibleSearchFeature"
    
    case bibleMccCheyneChallengeFeature = "BibleMccCheyneChallengeFeature"
    
    case settingFeature = "SettingFeature"
    
    case bibleFeedFeature = "BibleFeedFeature"
    
    public var name: String { self.rawValue }
    
    public var interfaceName: String {
      self.rawValue.replacingOccurrences(of: "Feature", with: "Interface")
    }
    
    public var testName: String {
      self.rawValue.replacingOccurrences(of: "Feature", with: "Tests")
    }
  }
  case presentation(Feature)
  
  // MARK: - Domain
  case domain
  
  // MARK: - Data
  case data
  case bible
  
  // MARK: - Helpers
  case core
  case common
  case designSystem
  
  public enum ThirdParties: String {
    case rxProxyThirdParty = "RxProxyThirdParty"
    case proxyThirdParty = "ProxyThirdParty"
    case rxFlowCommon = "RxFlowCommon"
  }
  
  case thirdParties
//  case rxFlowCommon
//  case rxProxyPackage
  
  public init?(rawValue: String) {
    if let feature = Feature(rawValue: rawValue) {
      self = .presentation(feature)
    } else {
      switch rawValue {
      case "App": self = .app
      case "Catalog": self = .catalog
      case "Domain": self = .domain
      case "Bible": self = .bible
      case "Data": self = .data
      case "Core": self = .core
      case "Common": self = .common
      case "DesignSystem": self = .designSystem
      case "ThridParties": self = .thirdParties
      default: return nil
      }
    }
  }
  
  public var rawValue: String {
    switch self {
    case .presentation(let feature):
      return feature.rawValue
    case .app: return "App"
    case .catalog: return "Catalog"
      
    case .domain: return "Domain"
      
    case .bible: return "Bible"
    case .data: return "Data"
    case .core: return "Core"
    case .common: return "Common"
    case .designSystem: return "DesignSystem"
    case .thirdParties: return "ThirdParties"
    }
  }

  
  // MARK: - Computed properties
  public var name: String {
    if case .presentation(let feature) = self {
      return feature.rawValue
    }
    return rawValue
  }
  
  public var interfaceName: String {
    if case .presentation(let feature) = self {
      return feature.interfaceName
    }
    return rawValue + "Interface"
  }
  
  public var testName: String {
    if case .presentation(let feature) = self {
      return feature.testName
    }
    return rawValue + "Tests"
  }
  
  public var path: ProjectDescription.Path {
    if case .presentation = self {
      return .relativeToRoot("Modules/Presentation/" + name)
    }
    return .relativeToRoot("Modules/" + name)
  }
  
  public var project: TargetDependency {
    .project(target: name, path: path)
  }
  
  public static var allCases: [Module] {
    return [
      .app,
      .domain,
      .bible,
      .data,
      .core,
      .common,
      .designSystem,
      .catalog
    ] + Feature.allCases.map { .presentation($0) }
  }
}

/// 근데 이거 주의해야할게 proejct내부 feature모듈에서, demo target할때는
/// 아래 project를 찾는게아니라
/// .project 로 참조하지않고
/// .target을 활용해야함.. 알겟지?
///
///
/// e.g.
///
/// proejct.swift에서 ( 바이블 노트 피쳐 )
///
/// let project = Porject(
///   name: Module.presentation(.bibleNoteFeature).rawValue),
///   dependencies: [
///   /// 여기서 자기꺼는 타겟으로! project로 주입하면안됨.
///     // OK
///     .interfaceTarget(module: .presentation(.bibleNoteFeature))
///
///     // Do not use
///   // .bibleNoteFeatureInterface ( 삐빅 ) ( 오류 입니다 )
///
///
///   -> 이렇게 해야함. .project(module ...
///       이렇게하면안되 그리고 아래 정의된 것들은 다 proejct기반임.
///             타 모듈에서 A모듈의 특정한 라이브러리 불러올 때 활용하는 것임
extension TargetDependency {
  public static var bibleHomeFeature: Self {
    featureProejct(of: .bibleHomeFeature)
  }
  
  public static var bibleHomeInterface: Self {
    .project(module: .presentation(.bibleHomeFeature), forInterface: true)
  }
  
  public static var bibleReadingFeature: Self {
    featureProejct(of: .bibleReadingFeature)
  }
  
  public static var bibleReadingInterface: Self {
    .project(module: .presentation(.bibleReadingFeature), forInterface: true)
  }
  
  // MARK: - Activity
  public static var myActivityFeature: Self {
    featureProejct(of: .myActivityFeature)
  }
  
  public static var myActivityInterface: Self {
    .project(module: .presentation(.myActivityFeature), forInterface: true)
  }
  
  public static var bibleHighlightFeature: Self {
    featureProejct(of: .bibleHighlightFeature)
  }
  
  public static var bibleHighlightInterface: Self {
    .project(module: .presentation(.bibleHighlightFeature), forInterface: true)
  }
  
  public static var bibleNoteFeature: Self {
    featureProejct(of: .bibleNoteFeature)
  }
  
  public static var bibleNoteHomeFeature: Self {
    featureProejct(of: .bibleNoteHomeFeature)
  }
  
  public static var bibleNoteHomeInterface: Self {
    .project(module: .presentation(.bibleNoteHomeFeature), forInterface: true)
  }
  
  public static var bibleNoteInterface: Self {
    .project(module: .presentation(.bibleNoteFeature), forInterface: true)
  }
  
  public static var bibleMccCheyneChallengeFeature: Self {
    featureProejct(of: .bibleMccCheyneChallengeFeature)
  }
  
  public static var bibleMccCheyneChallengeInterface: Self {
    .project(module: .presentation(.bibleMccCheyneChallengeFeature), forInterface: true)
  }
  
  public static var bibleHeartHistoryFeature: Self {
    featureProejct(of: .bibleHeartHistoryFeature)
  }
  
  public static var bibleHeartHistoryInterface: Self {
    .project(module: .presentation(.bibleHeartHistoryFeature), forInterface: true)
  }
  
  public static var bibleReadingChecklistFeature: Self {
    .project(module: .presentation(.bibleReadingChecklistFeature))
  }
  
  public static var bibleReadingChecklistInterface: Self {
    .project(module: .presentation(.bibleReadingChecklistFeature), forInterface: true)
  }
  
  // MARK: - Feed
  
  public static var bibleFeedFeature: Self {
    featureProejct(of: .bibleFeedFeature)
  }
  
  public static var bibleFeedInterface: Self {
    .project(module: .presentation(.bibleFeedFeature), forInterface: true)
  }
  
  public static var bibleSearchFeature: Self {
    featureProejct(of: .bibleSearchFeature)
  }
  
  public static var bibleSearchInterface: Self {
    .project(module: .presentation(.bibleSearchFeature), forInterface: true)
  }
  
  public static var settingFeature: Self {
    project(of: .presentation(.settingFeature))
  }
  
  public static var settingInterface: Self {
    .project(module: .presentation(.settingFeature), forInterface: true)
  }
  
  public static var domain: Self {
    project(of: .domain)
  }
  
  public static var domainEntity: Self {
    .project(module: .domain, additionalTargetName: "Entity")
  }
  
  public static var domainInterface: Self {
    .project(module: .domain, forInterface: true)
  }
  
  public static var data: Self {
    project(of: .data)
  }
  
  public static var core: Self {
    project(of: .core)
  }
  
  public static var coreInterface: Self {
    project(module: .core, forInterface: true)
  }
  
  public static var designSystem: Self {
    project(of: .designSystem)
  }
  
  public static var designSystemItems: Self {
    project(module: .designSystem, additionalTargetName: "Items")
  }
  
  public static var designSystemInterface: Self {
    project(module: .designSystem, forInterface: true)
  }
  
  public static var common: Self {
    project(of: .common)
  }
  
  public static var bible: Self {
    project(of: .bible)
  }
  
  public static var bibleInterface: Self {
    .project(module: .bible, forInterface: true)
  }
  
  public static var rxProxyThirdParty: Self {
    return .project(
      target: Module.ThirdParties.rxProxyThirdParty.rawValue,
      path: .relativeToRoot("Modules/ThirdParties"))
  }
  
  public static var proxyThirdParty: Self {
    return .project(
      target: Module.ThirdParties.proxyThirdParty.rawValue,
      path: .relativeToRoot("Modules/ThirdParties"))
  }
  
  public static var rxFlowCommon: Self {
    return .project(
      target: Module.ThirdParties.rxFlowCommon.rawValue,
      path: .relativeToRoot("Modules/ThirdParties"))
  }
  
  // MARK: - Helpers
  private static func project(of module: Module) -> Self {
    module.project
  }
  
  private static func featureProejct(of module: Module.Feature) -> Self {
    Module.presentation(module).project
  }
}
