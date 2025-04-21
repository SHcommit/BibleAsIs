import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.projectForModule(
  name: Module.common.rawValue,
  targets: [
    .target(
      module: .common,
      dependencies: [
        .proxyThirdParty,
        .domainEntity
      ])
  ]
)
