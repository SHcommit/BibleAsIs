import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.projectForApp(
  name: "BibleAsIsCatalogApp",
  targets: [
    .target(
      module: .catalog,
      product: .app,
      bundleId: Project.bundleId + "CatalogApp".lowercased(),
      infoPlist: .demo,
      dependencies: [
        .designSystem,
        .project(module: .designSystem, additionalTargetName: "Items"),
        .proxyThirdParty,
        .rxProxyThirdParty,
        .core,
        .domain
      ]
    )
  ]
)
