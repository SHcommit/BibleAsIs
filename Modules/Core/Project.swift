import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.projectForModule(
  name: Module.core.rawValue,
  targets: [
    .target(
      module: .core,
      resources: ["*.md"],
      dependencies: [
        .domainEntity,
        .common,
        .coreInterface,
        .proxyThirdParty
      ]),
    .interfaceTarget(
      module: .core,
      dependencies: [
        .domainInterface
      ]),
    .unitTestsTarget(module: .core)
  ]
)
