//
//  SourceFilesList+Helpers.swift
//  ProjectDescriptionHelpers
//
//  Created by 양승현 on 2/20/25.
//

import ProjectDescription


extension SourceFilesList {
  public static var interfaces: Self { ["Interfaces/**"] }
  
  public static var sources: Self { ["Sources/**"] }
  
  public static var tests: Self { ["Tests/**"] }
  
  public static func forDemo(_ fileName: String) -> Self {
    ["Sources/**", "\(fileName)/**"]
  }
  
  @available(*, deprecated, renamed: "-", message: "하.. 이거 잘못된거야 파일들을 인식못하네")
  public static func sources(withAppendingAdditionalFiles fileNames: [String]) -> SourceFilesList {
    var fileNames = fileNames
    fileNames.append("Sources/**")
    return sourceFilesList(globs: fileNames)
  }
}
