import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.projectForApp(
  name: Module.presentation(.settingFeature).rawValue,
  targets: [
    .target(
      module: .presentation(.settingFeature),
      dependencies: [
        .interfaceTarget(module: .presentation(.settingFeature)),
        .domainEntity,
        .domainInterface,
        
        .designSystem,
        .designSystemItems,
        .bibleInterface,
        .common,
        
        .rxProxyThirdParty,
        .proxyThirdParty
      ]
    ),
    .interfaceTarget(
      module: .presentation(.settingFeature),
      dependencies: [
        .domainEntity,
        .proxyThirdParty
      ]
    ),
    .demoTarget(
      feature: .settingFeature,
      dependencies: [
        .target(module: .presentation(.settingFeature)),
        .core,
        .data,
        .domain
      ])
  ]
)
