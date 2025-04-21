import ProjectDescription
import ProjectDescriptionHelpers

let isPrdEnvironment = BuildTarget.currentEnvironment() == .prd

/// 근데 난 뭐 개발자용으로도 파베가 있어도 될거같은데?,,
/// - > 아 파베 crashlytics 끼니까 넘 느려
 let resourceItems: [ResourceFileElement] = ["*.md", "Resources/**"] + (isPrdEnvironment ? [.googleServiceInfoPlist] : [])
// let resourceItems: [ResourceFileElement] = ["*.md"]

let _resources: ResourceFileElements = .resources(resourceItems)

let _scripts: [TargetScript] = [.swiftLint] + (isPrdEnvironment ? [.firebaseCrashlytics] : [])

let schemeName = "BibleAsIsApp" + (isPrdEnvironment ? "-Release" : "-Debug")
let configuration: ConfigurationName = isPrdEnvironment ? "Release" : "Debug"
let scheme = Scheme.scheme(
  name: schemeName,
  shared: true,
  buildAction: .buildAction(targets: ["BibleAsIs"]),
  runAction: .runAction(configuration: configuration),
  archiveAction: .archiveAction(configuration: configuration),
  profileAction: .profileAction(configuration: configuration),
  analyzeAction: .analyzeAction(configuration: configuration)
)

let target = Target.target(
  name: "BibleAsIs",
  product: .app,
  bundleId: Project.bundleId + ".App".lowercased(),
  infoPlist: .app,
  sources: .forDemo("Support"),
  resources: _resources,
  scripts: _scripts,
  dependencies: [
    // MARK: - Base
    .common,
    .core,
    .bible,
    .domain,
    .domainEntity,
    .data,
    .designSystem,
    .designSystemItems,
    
    // MARK: for My Activity page
    .bibleNoteHomeFeature,
    .bibleNoteFeature,
    .bibleHighlightFeature,
    .bibleHeartHistoryFeature,
    .bibleReadingChecklistFeature,
    .bibleMccCheyneChallengeFeature,
    .myActivityFeature,
    .myActivityInterface,
    
    // MARK: - for Bible Reading page
    .bibleSearchFeature,
    .settingFeature,
    .bibleReadingFeature,
    .bibleHomeFeature,
    .bibleHomeInterface,
    
    // MARK: - For feed page
    .bibleFeedFeature,
    .bibleFeedInterface,
    
    // MARK: - Third parties
    .proxyThirdParty,
    .rxProxyThirdParty,
  ] + (
    isPrdEnvironment ? [.firebaseAnalytics, .firebaseCrashlytics] : []
  )
)

let project = Project.projectForApp(
  name: "성경대로",
  targets: [target],
  additionalFiles: [],
  schemes: [scheme]
)
