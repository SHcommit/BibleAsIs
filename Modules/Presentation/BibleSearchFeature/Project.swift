import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.projectForApp(
  name: Module.presentation(.bibleSearchFeature).rawValue,
  targets: [
    .target(
      module: .presentation(.bibleSearchFeature),
      sources: ["Sources/**"],
      resources: ["*.md"],
      dependencies: [
        .common,
        .domainEntity,
        .domainInterface,
        .designSystem,
        .designSystemItems,
        
        .bibleSearchInterface,
        .bibleReadingInterface,
        .proxyThirdParty,
        .rxProxyThirdParty,
      ]),
    .interfaceTarget(
      module: .presentation(.bibleSearchFeature),
      dependencies: [
        .proxyThirdParty,
        .domainEntity
      ]),
    .demoTarget(
      feature: .bibleSearchFeature,
      dependencies: [
        .target(module: .presentation(.bibleSearchFeature)),
        .data,
        .core,
        .bible,
        .domain,
        .proxyThirdParty,
        .bibleSearchFeature
      ])
  ]
)
