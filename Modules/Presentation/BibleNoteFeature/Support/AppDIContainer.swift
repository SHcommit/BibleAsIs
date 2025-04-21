//
//  AppDIContainer.swift
//  bibleNoteInterface
//
//  Created by 양승현 on 3/26/25.
//

import Data
import Core
import Bible
import Domain
import Common
import Swinject
import Foundation
import BibleNoteFeature

struct AppDIContainer: AppDIContainable {
  var assembler: Swinject.Assembler
  
  var container: Swinject.Container
  
  init(assembler: Swinject.Assembler, container: Swinject.Container) {
    self.assembler = assembler
    self.container = container
  }
  
  init() {
    container = Container()
    assembler = Assembler([], container: container)
    
    assembler.apply(assemblies: [
      BibleAssembly(),
      CoreAssembly(),
      DataAssembly(),
      DomainAssembly(),
      BibleNoteAssembly()
    ])
  }
}
