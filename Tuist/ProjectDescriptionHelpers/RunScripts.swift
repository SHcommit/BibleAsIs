//
//  RunScripts.swift
//  ProjectDescriptionHelpers
//
//  Created by 양승현 on 2025/01/18.
//

import ProjectDescription

extension TargetScript {
  /// 경로 두개 존재..
  /// e.g. App/Project.swift
  /// Presentation/AFeature/Project.swift
  //  public static let swiftLint: TargetScript = .pre(
  //    script: """
  //      if [[ "$(uname -m)" == arm64 ]]; then
  //        export PATH="/opt/homebrew/bin:$PATH"
  //      fi
  //
  //      if which swiftlint > /dev/null; then
  //        # 첫 번째 경로를 시도
  //        SWIFTLINT_CONFIG_PATH1="$(pwd)/../../.swiftlint.yml"
  //        # 두 번째 경로를 시도
  //        SWIFTLINT_CONFIG_PATH2="$(pwd)/../../../../.swiftlint.yml"
  //
  //        # 첫 번째 경로 확인
  //        if [ -f "$SWIFTLINT_CONFIG_PATH1" ]; then
  //          swiftlint --config "$SWIFTLINT_CONFIG_PATH1"
  //        # 두 번째 경로 확인
  //        elif [ -f "$SWIFTLINT_CONFIG_PATH2" ]; then
  //          swiftlint --config "$SWIFTLINT_CONFIG_PATH2"
  //        else
  //          echo "warning: .swiftlint.yml file not found in either $SWIFTLINT_CONFIG_PATH1 or $SWIFTLINT_CONFIG_PATH2"
  //        fi
  //      else
  //        echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint.git"
  //      fi
  //    """,
  //    name: "SwiftLint",
  //    basedOnDependencyAnalysis: false
  //  )
  
  /// 경로 루트까지 찾아가도록!
  /// 근데 오류 중복
  ///
  /// 이게 하나의 프로젝트에서 여러 타겟이 동일한 swiftlint를 n개 씩 방출해냄..
  /// 앱이나 데모타겟만 하자
  public static let swiftLint: TargetScript = .pre(
    script: """
    if [[ "$(uname -m)" == arm64 ]]; then
      export PATH="/opt/homebrew/bin:$PATH"
    fi
  
    if which swiftlint > /dev/null; then
      ROOT_DIR=$(pwd)
      while [[ "$ROOT_DIR" != "/" && ! -f "$ROOT_DIR/.swiftlint.yml" ]]; do
        ROOT_DIR=$(dirname "$ROOT_DIR")
      done
  
      if [ -f "$ROOT_DIR/.swiftlint.yml" ]; then
        echo "SwiftLint config found at $ROOT_DIR/.swiftlint.yml"
        swiftlint --config "$ROOT_DIR/.swiftlint.yml"
      else
        echo "warning: .swiftlint.yml file not found in any parent directories from $(pwd)"
      fi
    else
      echo "warning: SwiftLint not installed. Install it with 'brew install swiftlint'"
    fi
  """,
    name: "SwiftLint",
    basedOnDependencyAnalysis: false
  )
  
//  public static let firebaseCrashlytics: TargetScript = .post(
//    script: """
//      echo "📦 Uploading dSYM to Firebase Crashlytics.. 제발 되라라라\n\n"
//      ../../scripts/upload-symbols \\
//        -gsp "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist" \\
//        -p ios "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}"
//    """,
//    name: "FirebaseCrashlytics",
//    inputPaths: [
//      "$(DWARF_DSYM_FOLDER_PATH)/$(DWARF_DSYM_FILE_NAME)/Contents/Resources/DWARF/$(TARGET_NAME)",
//      "$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)"
//    ],
//    basedOnDependencyAnalysis: false
//  )
  
//  public static let firebaseCrashlytics: TargetScript = .post(
//    script: """
//      echo "📦 Uploading dSYM to Firebase Crashlytics.. 제발 되라라라\n\n"
//      ../../scripts/run 
//    """,
//    name: "FirebaseCrashlytics",
//    inputPaths: [
//      "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}",
//      "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${PRODUCT_NAME}",
//      "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist",
//      "$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist",
//      "$(TARGET_BUILD_DIR)/$(EXECUTABLE_PATH)"
//    ],
//    basedOnDependencyAnalysis: false
//  )
  
//  public static let firebaseCrashlytics: TargetScript = .post(
//    script: """
//      echo "📦 Uploading dSYM to Firebase Crashlytics.. 제발 되라라라\n\n"
//      ../Tuist/.build/checkouts/firebase-ios-sdk/Crashlytics/run
//      -gsp "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist" \\
//      -p ios "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}"
//    """,
//    name: "FirebaseCrashlytics",
//    inputPaths: [
//      "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}",
//      "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${PRODUCT_NAME}",
//      "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist",
//      "$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist",
//      "$(TARGET_BUILD_DIR)/$(EXECUTABLE_PATH)"
//    ],
//    basedOnDependencyAnalysis: false
//  )
  
//  public static let firebaseCrashlytics: TargetScript = .post(
//    script: """
//    echo "📦 Uploading dSYM to Firebase Crashlytics"
//    "${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
//  """,
//    name: "FirebaseCrashlytics",
//    inputPaths: [
//      "$(DWARF_DSYM_FOLDER_PATH)/$(DWARF_DSYM_FILE_NAME)/Contents/Resources/DWARF/$(TARGET_NAME)",
//      "$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist"
//    ],
//    basedOnDependencyAnalysis: false
//  )
//



//  public static let googleServiceInfo: TargetScript = .pre(
//    script: """
//    echo "Copying GoogleService-Info.plist"
//    
//    case "${CONFIGURATION}" in
//      "Debug" )
//        cp -r "$SRCROOT/Config/firebase/GoogleService-Info-Dev.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
//        ;;
//      "Release" )
//        cp -r "$SRCROOT/Config/firebase/GoogleService-Info-Prod.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
//        ;;
//      *)
//        ;;
//    esac
//    """,
//    name: "GoogleService Info"
//  )
  
  public static let firebaseCrashlytics: TargetScript = .post(
    script: """
    echo "📦 Uploading dSYM to Firebase Crashlytics ... 제발 되라!! 제발!"
    ROOT_PATH="$SRCROOT"
    while [ "$ROOT_PATH" != "/" ]; do
      if [ -d "$ROOT_PATH/Tuist" ]; then
        echo "Found Tuist directory: $ROOT_PATH/Tuist"
        break
      fi
      ROOT_PATH=$(dirname "$ROOT_PATH")
    done
  
    "${ROOT_PATH}/Tuist/.build/checkouts/firebase-ios-sdk/Crashlytics/run"
  """,
    name: "FirebaseCrashlytics",
    inputPaths: [
      "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}",
      "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${PRODUCT_NAME}",
      "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist",
      "$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist",
      "$(TARGET_BUILD_DIR)/$(EXECUTABLE_PATH)"
//      .glob(.relativeToManifest("${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}")),
//      .glob(.relativeToManifest("$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)"))
    ],
    basedOnDependencyAnalysis: false
  )
  
  
  
//  public static let firebaseCrashlytics: TargetScript = .post(
//    script: "${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run",
//    name: "FirebaseCrashlytics",
//    inputPaths: [
//      "$(DWARF_DSYM_FOLDER_PATH)/$(DWARF_DSYM_FILE_NAME)/Contents/Resources/DWARF/$(TARGET_NAME)",
//      "$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)"
//    ],
//    basedOnDependencyAnalysis: false
//  )
}
