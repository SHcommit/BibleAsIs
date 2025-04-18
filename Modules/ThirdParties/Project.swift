import ProjectDescription
import ProjectDescriptionHelpers

/// lottie는 DesignSystem에만 써서 추가안함.
let project = Project.projectForModule(
  name: Module.thirdParties.rawValue,
  targets: [
    .target(
      name: Module.ThirdParties.rxProxyThirdParty.rawValue,
      product: .staticFramework,
      bundleId: nil,
      sources: ["RxProxyThirdPartySources/**"],
      dependencies: [
        .rxSwift,
        .rxCocoa,
        .rxRelay,
        .reactorKit
      ]
    ),
    .target(
      name: Module.ThirdParties.proxyThirdParty.rawValue,
      product: .staticFramework,
      bundleId: nil,
      sources: ["ProxyThirdPartySources/**"],
      dependencies: [
        .then,
        .swinject
      ]
    )
//    .target(
//      name: Module.ThirdParties.rxFlowCommon.rawValue,
//      product: .framework,
//      bundleId: nil,
//      sources: ["RxFlowCommonSources/**"],
//      dependencies: [
//        .target(name: "RxProxyThirdParty")
//      ])
  ]
)
