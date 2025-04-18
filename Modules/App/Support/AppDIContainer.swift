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

import BibleNoteHomeFeature
import BibleNoteFeature
import BibleHighlightFeature
import BibleHeartHistoryFeature
import BibleReadingChecklistFeature
import BibleMccCheyneChallengeFeature
import MyActivityFeature

import SettingFeature
import BibleHomeFeature
import BibleFeedFeature
import BibleSearchFeature
import BibleReadingFeature

struct AppDIContainer: AppDIContainable {
  var assembler: Swinject.Assembler
  
  var container: Swinject.Container
  
  init() {
    container = Container()
    assembler = Assembler(container: container)
    
    assembler.apply(assemblies: [
      CoreAssembly(),
      BibleAssembly(),
      DomainAssembly(),
      DataAssembly(),
      
      // MARK: for My Activity page
      BibleNoteHomeAssembly(),
      BibleNoteAssembly(),
      BibleHighlightAssembly(),
      BibleHeartHistoryAssembly(),
      BibleReadingChecklistAssembly(),
      BibleMccCheyneChallengeAssembly(),
      MyActivityAssembly(),
      
      // MARK: - for Bible Reading page
      BibleSearchAssembly(),
      SettingAssembly(),
      BibleReadingAssembly(),
      BibleHomeFeatureAssembly(),
      
      // MARK: - For feed page
      BibleFeedAssembly()
    ])
  }
}
