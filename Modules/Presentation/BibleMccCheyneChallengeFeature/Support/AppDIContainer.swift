//
//  AppDIContainer.swift
//  BibleMccCheyneChallengeFeature
//
//  Created by 양승현 on 3/26/25.
//

import Data
import Core
import Bible
import Domain
import Common
import Swinject
import BibleMccCheyneChallengeFeature
// import BibleReadingFeature

struct AppDIContainer: AppDIContainable {
  var assembler: Swinject.Assembler
  
  var container: Swinject.Container
  
  init() {
    self.container = Container()
    self.assembler = Assembler([], container: container)
    
    assembler.apply(assemblies: [
      BibleAssembly(),
      CoreAssembly(),
      DataAssembly(),
      DomainAssembly(),
//      BibleReadingAssembly(),
      BibleMccCheyneChallengeAssembly()
    ])
  }
}
