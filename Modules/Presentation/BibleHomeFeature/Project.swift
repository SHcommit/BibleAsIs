import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.projectForApp(
  name: Module.presentation(.bibleHomeFeature).rawValue,
  targets: [
    .target(
      module: .presentation(.bibleHomeFeature),
      resources: ["README.md"],
      dependencies: [
        // MARK: Feature Interface
        /// 여기서 이거 씀녀 안됨 이거는 .proejct로 불러오는거임
        /// .bibleHomeFeature
        .interfaceTarget(module: .presentation(.bibleHomeFeature)),
        .bibleSearchInterface,
        .bibleReadingInterface,
        
        // Other
        .common,
        .domainEntity,
        .domainInterface,
        
        .coreInterface,
        
        .designSystem,
        .designSystemItems,
        .designSystemInterface,
        
        // MARK: Third Parties
        .rxProxyThirdParty,
        .proxyThirdParty
      ]),
    .interfaceTarget(
      module: .presentation(.bibleHomeFeature),
      dependencies: [
        .domainEntity,
        .proxyThirdParty
      ]),
    .demoTarget(
      feature: .bibleHomeFeature,
      dependencies: [
        .target(module: .presentation(.bibleHomeFeature)),
        
        // 이건 외부 모듈에서
//        .bibleHomeFeature,
        
        .data,
        .core,
        .domain,
        .proxyThirdParty,
        
        // MARK: - For Test
        .bibleReadingFeature,
        .bibleSearchFeature
      ])
  ]
)
