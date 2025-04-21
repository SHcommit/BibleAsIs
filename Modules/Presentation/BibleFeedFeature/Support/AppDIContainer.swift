//
//  AppDIContainer.swift
//  BibleHighlightFeature
//
//  Created by 양승현 on 3/27/25.
//

import Data
import Core
import Bible
import Domain
import Common
import Swinject
import Foundation

import BibleFeedFeature
// for Tests
import BibleNoteHomeFeature
import BibleHeartHistoryFeature
import BibleMccCheyneChallengeFeature
import BibleReadingFeature
import BibleReadingChecklistFeature

struct AppDIContainer: AppDIContainable {
  var assembler: Swinject.Assembler
  
  var container: Swinject.Container
  
  init() {
    container = Container()
    assembler = Assembler(container: container)
    
    assembler.apply(assemblies: [
      CoreAssembly(),
      BibleAssembly(),
      DataAssembly(),
      DomainAssembly(),
      
      BibleFeedAssembly(),
      
      // forTests
      BibleNoteHomeAssembly(),
      BibleHeartHistoryAssembly(),
      BibleMccCheyneChallengeAssembly(),
      BibleReadingAssembly(),
      BibleReadingChecklistAssembly()
    ])
  }
}
