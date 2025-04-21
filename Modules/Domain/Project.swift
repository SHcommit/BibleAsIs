import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.projectForModule(
  name: Module.domain.rawValue,
  targets: [
    .target(
      module: .domain, 
      sources: .sources,
      dependencies: [
        .target(module: .domain, additionalName: "Entity"),
        .target(module: .domain, additionalName: "Interface"),
        .proxyThirdParty
      ]),
    .target(
      module: .domain, additionalTargetName: "Entity",
      sources: ["Entities/**"]
    ),
    .interfaceTarget(
      module: .domain,
      dependencies: [
        .target(module: .domain, additionalName: "Entity")
      ]
    ),
    .unitTestsTarget(module: .domain, dependencies: [
      .target(module: .domain, additionalName: "Entity"),
      .target(module: .domain, additionalName: "Interface"),
      .domain
    ])
  ]
)
