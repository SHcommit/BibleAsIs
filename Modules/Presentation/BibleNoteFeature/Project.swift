import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.projectForApp(
  name: Module.presentation(.bibleNoteFeature).rawValue,
  targets: [
    .target(
      module: .presentation(.bibleNoteFeature),
      sources: ["Sources/**"],
      dependencies: [
        .interfaceTarget(module: .presentation(.bibleNoteFeature)),
        .designSystem,
        .designSystemItems,
        .common,
        .coreInterface,
        .domainEntity,
        .domainInterface,
        .rxProxyThirdParty,
        .proxyThirdParty
      ]),
    .interfaceTarget(
      module: .presentation(.bibleNoteFeature),
      dependencies: [
        .domainEntity,
        .proxyThirdParty
      ]),
    .demoTarget(
      feature: .bibleNoteFeature,
      dependencies: [
        .target(module: .presentation(.bibleNoteFeature)),
        .interfaceTarget(module: .presentation(.bibleNoteFeature)),
        
        .domain,
        .bible,
        .data,
        .common,
        .core,
        
        .rxProxyThirdParty,
        .proxyThirdParty
      ])
  ]
)
