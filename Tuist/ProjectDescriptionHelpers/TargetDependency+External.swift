//
//  TargetDependency+External.swift
//  ProjectDescriptionHelpers
//
//  Created by 양승현 on 3/11/25.
//

import ProjectDescription

// MARK: - Third party: )
extension TargetDependency {
  public static var rxSwift: Self {
    .external(name: "RxSwift-Dynamic")
  }
  public static var reactorKit: Self {
    .external(name: "ReactorKit")
  }
  
  public static var then: Self {
    .external(name: "Then")
  }
  
  public static var rxCocoa: Self {
    .external(name: "RxCocoa-Dynamic")
  }
  
//  public static var rxFlow: Self {
//    .external(name: "RxFlow")
//  }
  
  public static var rxRelay: Self {
    .external(name: "RxRelay-Dynamic")
  }
  
  public static var lottie: Self {
    .external(name: "Lottie")
  }
  
  public static var swinject: Self {
    .external(name: "Swinject")
  }
  
  public static var firebaseCrashlytics: Self {
    .external(name: "FirebaseCrashlytics")
  }
  
  public static var firebaseAnalytics: Self {
    .external(name: "FirebaseAnalytics")
  }
  
  public static var firebaseCore: Self {
    .external(name: "FirebaseCore")
  }
    
  public static var acknowList: Self {
    .external(name: "AcknowList")
  }
}
