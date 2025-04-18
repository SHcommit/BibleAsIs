//
//  AppDIContainer.swift
//  JourneyOfFaithBibleHomeFeatureDemoApp
//
//  Created by 양승현 on 3/23/25.
//

import Data
import Core
import Bible
import Domain
import Common
import Swinject
import Foundation
import MyActivityFeature

final class AppDIContainer: AppDIContainable {
  private(set) var assembler: Assembler
  
  private(set) var container: Container
  
  init() {
    self.container = Container()
    self.assembler = Assembler([], container: container)
    
    assembler.apply(assemblies: [
      BibleAssembly(),
      CoreAssembly(),
      DataAssembly(),
      DomainAssembly(),
      MyActivityAssembly()
    ] + Self.additionalAssembliesForTests())
  }
}

// MARK: - ForTests
import BibleNoteHomeFeature
import BibleHighlightFeature
import BibleHeartHistoryFeature
import BibleReadingChecklistFeature
import BibleMccCheyneChallengeFeature

extension AppDIContainer {
  static func additionalAssembliesForTests() -> [Swinject.Assembly] {
    [BibleNoteHomeAssembly(),
     BibleHighlightAssembly(),
     BibleHeartHistoryAssembly(),
     BibleReadingChecklistAssembly(),
     BibleMccCheyneChallengeAssembly()]
  }
}
