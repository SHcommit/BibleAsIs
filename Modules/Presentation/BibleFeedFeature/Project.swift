import ProjectDescription
import ProjectDescriptionHelpers
let project = Project.projectForApp(
  name: Module.presentation(.bibleFeedFeature).rawValue,
  targets: [
    .target(
      module: .presentation(.bibleFeedFeature),
      resources: [
        .glob(pattern: Path.relativeToRoot("Tuist/Package.resolved"), excluding: [], tags: [], inclusionCondition: nil),
      ]
      ,
      dependencies: [
        // MARK: Feature Interface
        .interfaceTarget(module: .presentation(.bibleFeedFeature)),
        .bibleNoteHomeInterface,
        .bibleHeartHistoryInterface,
        .bibleMccCheyneChallengeInterface,
        .bibleReadingInterface,
        .bibleReadingChecklistInterface,
        
        // MARK: - Other
        .common,
        .coreInterface,
        .domainEntity,
        .domainInterface,
        .designSystem,
        .designSystemItems,
        
        // MARK: ThridParty
        .rxProxyThirdParty,
        .proxyThirdParty,
        .acknowList
      ]),
    .interfaceTarget(
      module: .presentation(.bibleFeedFeature),
      dependencies: [
        .domainEntity,
        .proxyThirdParty,
        .designSystemItems,
      ]),
    .demoTarget(
      feature: .bibleFeedFeature,
      dependencies: [
        // MARK: - Feature
        .target(module: .presentation(.bibleFeedFeature)),
        
        // for tests
        .bibleNoteHomeFeature,
        .bibleHeartHistoryFeature,
        .bibleMccCheyneChallengeFeature,
        .bibleReadingFeature,
        .bibleReadingChecklistFeature,
        
        // MARK: - Other
        .bible,
        .common,
        .core,
        .domain,
        .data,
        
        // MARK: - Third party
        .proxyThirdParty
      ])
  ]
)
