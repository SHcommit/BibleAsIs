//
//  ResourceExtension.swift
//  ProjectDescriptionHelpers
//
//  Created by 양승현 on 2025/01/17.
//

import Foundation
import ProjectDescription

public extension ProjectDescription.ResourceFileElements {
  static let `default`: ProjectDescription.ResourceFileElements = ["Resources/**"]
}

public extension ProjectDescription.ResourceFileElement {
  static var googleServiceInfoPlist: Self {
    Self.glob(pattern: Path.relativeToRoot("Config/GoogleService-Info.plist"), excluding: [], tags: [], inclusionCondition: nil)
  }
  
//  static var acknowledgementsPlist: Self {
//    Self.glob(pattern: Path.relativeToRoot("Config/Acknowledgements.plist"), excluding: [], tags: [], inclusionCondition: nil)
//  }
  
  static var resources: Self {
    .glob(pattern: "Resources/**", excluding: [], tags: [], inclusionCondition: nil)
  }
}
