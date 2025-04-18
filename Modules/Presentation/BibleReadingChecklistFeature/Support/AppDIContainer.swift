//
//  AppDIContainer.swift
//  BibleReadingChecklistFeature
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
import BibleReadingChecklistFeature

struct AppDIContainer: AppDIContainable {
  var assembler: Swinject.Assembler
  
  var container: Swinject.Container
  
  init() {
    container = Container()
    assembler = Assembler(container: container)
    
    assembler.apply(assemblies: [
      BibleAssembly(),
      DataAssembly(),
      CoreAssembly(),
      DomainAssembly(),
      BibleReadingChecklistAssembly()
    ])
  }
}
