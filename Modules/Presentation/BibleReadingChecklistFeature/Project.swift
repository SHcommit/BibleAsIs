import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.projectForApp(
  name: Module.presentation(.bibleReadingChecklistFeature).rawValue,
  targets: [
    .target(
      module: .presentation(.bibleReadingChecklistFeature),
      dependencies: [
        .interfaceTarget(module: .presentation(.bibleReadingChecklistFeature)),
        
        .domainEntity,
        .domainInterface,
        .designSystem,
        .designSystemItems,
        .common,
        .rxProxyThirdParty,
        .proxyThirdParty,
        .coreInterface
      ]),
    .interfaceTarget(
      module: .presentation(.bibleReadingChecklistFeature),
      dependencies: [
        .domainEntity
      ]),
    .demoTarget(
      feature: .bibleReadingChecklistFeature,
      dependencies: [
        .target(module: .presentation(.bibleReadingChecklistFeature)),
        .interfaceTarget(module: .presentation(.bibleReadingChecklistFeature)),
        .data,
        .core,
        .bible,
        .domain,
        .common,
        .proxyThirdParty
      ])
  ]
)
