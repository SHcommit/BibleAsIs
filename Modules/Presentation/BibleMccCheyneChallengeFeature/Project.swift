import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.projectForApp(
  name: Module.presentation(.bibleMccCheyneChallengeFeature).rawValue,
  targets: [
    .target(
      module: .presentation(.bibleMccCheyneChallengeFeature),
      sources: ["Sources/**"],
      resources: ["*.md"],
      dependencies: [
        .interfaceTarget(module: .presentation(.bibleMccCheyneChallengeFeature)),
        .domainEntity,
        .domainInterface,
        .designSystem,
        .designSystemItems,
        
        .bibleReadingInterface,
        
        .rxProxyThirdParty,
        .proxyThirdParty
        ]),
    .interfaceTarget(
      module: .presentation(.bibleMccCheyneChallengeFeature),
      dependencies: [
        .domainEntity,
        .designSystemItems,
        .proxyThirdParty
      ]),
    .demoTarget(
      feature: .bibleMccCheyneChallengeFeature,
      dependencies: [
        .target(module: .presentation(.bibleMccCheyneChallengeFeature)),
        .core,
        .bible,
        .domain,
        .data,
        .common,
        .swinject
      ])
  ]
)
