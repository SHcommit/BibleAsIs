//
//  FeedSettingReactor.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 4/10/25.
//

import Common
import RxSwift
import Foundation
import ReactorKit
import DomainEntity
import DomainInterface

final class FeedSettingReactor: Reactor {
  enum Action {
    case viewDidLoad
    case displayAppearanceUpdated(DisplayAppearance)
  }
  
  enum Mutation {
    case displayApperanceSet(DisplayAppearance)
    case viewDidLoadCompletionSet(Bool)
    
    case displayAppearanceUpdateCompletionSet(Bool)
  }
  
  struct State {
    var appearance: DisplayAppearance = .default
    
    var viewDidLoadCompletion: Bool = false
    var displayAppearanceUpdateCompletion: Bool = false
  }
  
  var initialState: State = .init()
  
  private let userSystemAppearanceUseCase: UserSystemSettingAppearanceUpdateUseCase
  
  init(userSystemAppearanceUseCase: UserSystemSettingAppearanceUpdateUseCase) {
    self.userSystemAppearanceUseCase = userSystemAppearanceUseCase
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return Observable.concat([
        .just(.displayApperanceSet(userSystemAppearanceUseCase.fetchAppearance())),
        .just(.viewDidLoadCompletionSet(true)),
        .just(.viewDidLoadCompletionSet(false))
      ])
    case .displayAppearanceUpdated(let userPickNewAppearance):
      userSystemAppearanceUseCase.updateAppearance(userPickNewAppearance)
      return Observable.concat([
        .just(.displayApperanceSet(userPickNewAppearance)),
        .just(.displayAppearanceUpdateCompletionSet(true)),
        .just(.displayAppearanceUpdateCompletionSet(false))
      ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .displayApperanceSet(let fetchedDisplayAppearance):
      newState.appearance = fetchedDisplayAppearance
    case .viewDidLoadCompletionSet(let hasCompleted):
      newState.viewDidLoadCompletion = hasCompleted
    case .displayAppearanceUpdateCompletionSet(let displayAppearanceUpdatedCompletion):
      newState.displayAppearanceUpdateCompletion = displayAppearanceUpdatedCompletion
    }
    return newState
  }
}
