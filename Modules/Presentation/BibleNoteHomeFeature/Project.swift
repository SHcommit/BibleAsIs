import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.projectForApp(
  name: Module.presentation(.bibleNoteHomeFeature).rawValue,
  targets: [
    .target(
      module: .presentation(.bibleNoteHomeFeature),
      resources: ["README.md"],
      dependencies: [
        .interfaceTarget(module: .presentation(.bibleNoteHomeFeature)),
        
        .bibleNoteInterface,
        
        .domainEntity,
        .domainInterface,
        .designSystem,
        .designSystemItems,
        .common,
        .rxProxyThirdParty,
        .proxyThirdParty
      ]),
    .interfaceTarget(
      module: .presentation(.bibleNoteHomeFeature),
      dependencies: [
        .domainEntity,
        .bibleNoteInterface,
        .proxyThirdParty
      ]),
    .demoTarget(
      feature: .bibleNoteHomeFeature,
      dependencies: [
        .target(module: .presentation(.bibleNoteHomeFeature)),
        .data,
        .core,
        .bible,
        .domain,
        .common,
        .proxyThirdParty,
        
        // for tests
        .bibleNoteFeature
      ])
  ]
)
