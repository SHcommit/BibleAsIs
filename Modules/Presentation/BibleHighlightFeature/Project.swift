import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.projectForApp(
  name: Module.presentation(.bibleHighlightFeature).rawValue,
  targets: [
    .target(
      module: .presentation(.bibleHighlightFeature),
      dependencies: [
        .interfaceTarget(module: .presentation(.bibleHighlightFeature)),
        .bibleReadingInterface,
        .domainEntity,
        .domainInterface,
        .designSystem,
        .designSystemItems,
        .common,
        .rxProxyThirdParty,
        .proxyThirdParty
      ]),
    .interfaceTarget(
      module: .presentation(.bibleHighlightFeature),
      dependencies: [
        .domainEntity
      ]),
    .demoTarget(
      feature: .bibleHighlightFeature,
      dependencies: [
        .target(module: .presentation(.bibleHighlightFeature)),
        .interfaceTarget(module: .presentation(.bibleHighlightFeature)),
        .data,
        .core,
        .bible,
        .domain,
        .common,
        .proxyThirdParty
      ])
  ]
)
