import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.projectForModule(
  name: Module.data.rawValue,
  targets: [
    .target(
      module: .data,
      sources: .sources,
      dependencies: [
        .domainEntity,
        .domainInterface,
        .common,
        .proxyThirdParty,
        .project(module: .core, forInterface: true),
        .bibleInterface
      ])
    ,
    .unitTestsTarget(module: .data)
  ]
)
