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
import Swinject
import Foundation
import BibleReadingFeature

final class AppDIContainer {
  private(set) var assembler: Assembler
  
  private(set) var container: Container
  
  var resolver: Resolver {
    assembler.resolver
  }
  
  init() {
    self.container = Container()
    self.assembler = Assembler([], container: container)
    
    assembler.apply(assemblies: [
      BibleAssembly(),
      CoreAssembly(),
      DataAssembly(),
      DomainAssembly(),
      BibleReadingAssembly()
    ])
  }
}
