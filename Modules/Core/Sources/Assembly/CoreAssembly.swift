//
//  CoreAssembly.swift
//  Core
//
//  Created by 양승현 on 3/23/25.
//

import Swinject
import Foundation
import CoreInterface

public final class CoreAssembly: Swinject.Assembly {
  public init() { }
  
  public func assemble(container: Container) {
    
    container.register(TextHashable.self) { _ in
      TextHasher.shared
    }
    
    container.register(CalendarServiceProtocol.self) { _ in
      CalendarService.shared
    }
    
    container.register(BibleReadingAnalyzer.self, factory: { r in
      let calendarService = r.resolve(CalendarServiceProtocol.self)!
      return BibleReadingAnalyzer(calendarService: calendarService)
    })
    
    container.register(BibleSleepAudioPlayerProtocol.self) { (_, dataSource: BibleSleepAudioPlayDataSource) in
      BibleSleepAudioPlayer(dataSource: dataSource)
    }
    
    container.register(UserStorageProtocol.self) { _ in
      return DefaultUserStorageDAO()
    }
    
    container.register(BibleReadingAnalyzable.self) { r in
      let calendarService = r.resolve(CalendarServiceProtocol.self)!
      return BibleReadingAnalyzer(calendarService: calendarService)
    }
  }
}
