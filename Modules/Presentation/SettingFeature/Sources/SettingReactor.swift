//
//  SettingReactor.swift
//  SettingFeature
//
//  Created by 양승현 on 3/12/25.
//

import Common
import RxSwift
import ReactorKit
import Foundation
import DomainEntity
import DomainInterface

public final class SettingReactor: Reactor {
  // MARK: - Constants
  public enum Action {
    case appearanceUpdate(DisplayAppearance)
    case fontSizeUpdate(CGFloat)
    case refresh
  }
  
  public enum Mutation {
    case appearanceUpdated(Bool)
    case fontUpdated(Bool)
    case updatedSystemSettings(UserSystemSettings)
    case systemSettingsHasUpdated(Bool)
//    case unexpectedErrorOccured(String)
  }
  
  public struct State {
    var appearanceUpdated = false
    var fontUpdated = false
    
    var systemSettings: UserSystemSettings = .init(fontSize: 13.0, appearance: .default)
    var shouldRefresh: Bool = false
//    var unexpectedErrorOccured = ""
  }
  
  // MARK: - Properties
  public var initialState: State = State()
  
  private let fontUpdateUseCase: UserSystemSettingFontUseCase
  
  private let appearanceUpdateUseCase: UserSystemSettingAppearanceUpdateUseCase
  
  public var appearance: DisplayAppearance {
    currentState.systemSettings.appearance
  }
  
  public var fontSize: CGFloat {
    currentState.systemSettings.fontSize
  }
  
  // MARK: - Lifecycle
  public init(
    fontUpdateUseCase: UserSystemSettingFontUseCase,
    appearanceUpdateUseCase: UserSystemSettingAppearanceUpdateUseCase
  ) {
    self.fontUpdateUseCase = fontUpdateUseCase
    self.appearanceUpdateUseCase = appearanceUpdateUseCase
  }
  
  // MARK: - Reactor
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .appearanceUpdate(let displayAppearance):
      appearanceUpdateUseCase.updateAppearance(displayAppearance)
      var newSettings = currentState.systemSettings
      newSettings.appearance = displayAppearance
      return Observable.concat([
        .just(.updatedSystemSettings(newSettings)),
        .just(.appearanceUpdated(true)),
        .just(.appearanceUpdated(false))
      ])
    case .fontSizeUpdate(let cGFloat):
      fontUpdateUseCase.updateFontSize(cGFloat)
      var newSettings = currentState.systemSettings
      newSettings.fontSize = cGFloat
      return Observable.concat([
        .just(.updatedSystemSettings(newSettings)),
        .just(.fontUpdated(true)),
        .just(.fontUpdated(false))
      ])
    case .refresh:
      let fontSize = fontUpdateUseCase.fetchFontSize()
      let appearance = appearanceUpdateUseCase.fetchAppearance()
      return Observable.concat([
        .just(.updatedSystemSettings(.init(fontSize: fontSize, appearance: appearance))),
        .just(.systemSettingsHasUpdated(true)),
        .just(.systemSettingsHasUpdated(false))
      ])
    }
  }
  
  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .appearanceUpdated(let hasUpdated):
      newState.appearanceUpdated = hasUpdated
    case .fontUpdated(let hasUpdated):
      newState.fontUpdated = hasUpdated
    case .updatedSystemSettings(let fetchedSystemSettings):
      newState.systemSettings = fetchedSystemSettings
    case .systemSettingsHasUpdated(let hasUpdated):
      newState.shouldRefresh = hasUpdated
    }
    return newState
  }
}
