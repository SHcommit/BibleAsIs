import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.projectForApp(
  name: Module.presentation(.bibleReadingFeature).rawValue,
  targets: [
    .target(
      module: .presentation(.bibleReadingFeature),
      resources: ["*.md"],
      dependencies: [
        .interfaceTarget(module: .presentation(.bibleReadingFeature)),
        
        .domainEntity,
        .domainInterface,
        .designSystem,
        .designSystemItems,
        
        .settingInterface,
        .bibleNoteInterface,
        
        .rxProxyThirdParty,
        .proxyThirdParty
      ]
    ),
    .interfaceTarget(
      module: .presentation(.bibleReadingFeature),
      dependencies: [
        .domainEntity,
        .proxyThirdParty,
        .designSystemItems
      ]),
    .demoTarget(
      feature: .bibleReadingFeature,
      dependencies: [
        .target(module: .presentation(.bibleReadingFeature)),
        .interfaceTarget(module: .presentation(.bibleReadingFeature)),
        .data,
        .domain,
        .core,
        .common
//        forTests
//        .settingFeature,
//        .bibleNoteFeature
      ])
  ]
)
