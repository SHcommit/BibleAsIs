import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.projectForApp(
  name: Module.presentation(.myActivityFeature).rawValue,
  targets: [
    .target(
      module: .presentation(.myActivityFeature),
      resources: ["*.md"],
      dependencies: [
        .interfaceTarget(module: .presentation(.myActivityFeature)),
        .bibleNoteHomeInterface,
        .bibleHighlightInterface,
        .bibleHeartHistoryInterface,
        .bibleReadingChecklistFeature,
        .bibleMccCheyneChallengeInterface,
        
        .common,
        .domainEntity,
        .domainInterface,
        .designSystem,
        .designSystemItems,
        
        .rxProxyThirdParty,
        .proxyThirdParty
      ]
    ),
    .interfaceTarget(
      module: .presentation(.myActivityFeature),
      dependencies: [
        .proxyThirdParty
      ]
    ),
    .demoTarget(
      feature: .myActivityFeature,
      dependencies: [
        .target(module: .presentation(.myActivityFeature)),
        .interfaceTarget(module: .presentation(.myActivityFeature)),
        
        .data,
        .core,
        .domain,
        .bible,
        .proxyThirdParty,
        
        // forTests
        .bibleNoteHomeFeature,
        .bibleHighlightFeature,
        .bibleHeartHistoryFeature,
        .bibleReadingChecklistFeature,
        .bibleMccCheyneChallengeFeature
      ])
  ]
)
