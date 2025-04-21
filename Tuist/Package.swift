// swift-tools-version:5.9

//import PackageDescription

#if TUIST
import ProjectDescription
import ProjectDescriptionHelpers

nonisolated(unsafe) let packageSettings = PackageSettings(
  // Customize the product types for specific package product
  // Default is .staticFramework
  // productTypes: ["Alamofire": .framework,]
  productTypes: [
    "Swinject": .staticFramework,
    "RxSwift": .framework,
    "ReactorKit": .staticFramework,
    "RxRelay": .framework,
//    "RxFlow": .framework,
    "lottie-spm": .staticFramework,
    "Then": .staticFramework, // default is .staticFramework
    "AcknowList": .staticFramework,
    "FirebaseCrashlytics": .staticFramework,
    "FirebaseCore": .staticFramework,
    "FirebaseAnalytics": .staticFramework
  ],
  baseSettings: .settings(
    configurations: [
      .debug(name: .debug),
      .release(name: .release)
  ])
)
#endif

import PackageDescription
nonisolated(unsafe) let package = Package(
  name: "BibleAsIs",
  dependencies: [
    // Add your own dependencies here:
    // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
    // You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies

      .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.8.0")),
    .package(url: "https://github.com/devxoul/Then", from: "2.0.0"),
    .package(url: "https://github.com/ReactorKit/ReactorKit.git", .upToNextMajor(from: "3.0.0")),
    .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.5.0"),
    .package(url: "https://github.com/Swinject/Swinject.git", from: "2.8.0"),
//    .package(url: "https://github.com/RxSwiftCommunity/RxFlow.git", .upToNextMajor(from:"2.10.0")),
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMinor(from: "10.24.0")),
    .package(url: "https://github.com/vtourraine/AcknowList.git", from: "2.0.0")
  ], targets: [
    .target(
      name: "BibleAsIs", dependencies: [
        .product(name: "RxSwift-Dynamic", package: "RxSwift"),
        .product(name: "RxCocoa-Dynamic", package: "RxSwift"),
        .product(name: "RxRelay-Dynamic", package: "RxSwift"),
//        .product(name: "RxFlow", package: "RxFlow"),
        .product(name: "ReactorKit", package: "ReactorKit"),
        .product(name: "Then", package: "Then"),
        .product(name: "Lottie", package: "lottie-spm"),
        .product(name: "Swinject", package: "Swinject"),
        .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
        .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
        .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
        .product(name: "AcknowList", package: "AcknowList"),
      ])
  ]
)
