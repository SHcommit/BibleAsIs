import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.projectForApp(
  name: Module.presentation(.bibleHeartHistoryFeature).rawValue,
  targets: [
    .target(
      module: .presentation(.bibleHeartHistoryFeature),
      dependencies: [
        .interfaceTarget(module: .presentation(.bibleHeartHistoryFeature)),
        .domainEntity,
        .domainInterface,
        .designSystem,
        .designSystemItems,
        
        .common,
        .rxProxyThirdParty,
        .proxyThirdParty
      ]),
    .interfaceTarget(
      module: .presentation(.bibleHeartHistoryFeature),
      dependencies: [
        .domainEntity
      ]),
    .demoTarget(
      feature: .bibleHeartHistoryFeature,
      dependencies: [
        .target(module: .presentation(.bibleHeartHistoryFeature)),
        .data,
        .core,
        .bible,
        .domain,
        .common
      ])
  ]
)
