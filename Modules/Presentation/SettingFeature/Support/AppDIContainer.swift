//
//  AppDIContainer.swift
//  SettingFeatureDemoApp
//
//  Created by 양승현 on 3/23/26.
//

import Data
import Core
import Bible
import Domain
import Swinject
import Foundation
import SettingFeature

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
      CoreAssembly(),
      DataAssembly(),
      DomainAssembly(),
      SettingAssembly()
    ])
  }
}
