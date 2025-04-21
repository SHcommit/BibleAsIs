//
//  BibleReadingPlanHomeReactor.swift
//  MyActivityFeature
//
//  Created by 양승현 on 3/6/25.
//

import Common
import RxSwift
import ReactorKit
import Foundation
import DomainEntity
import DomainInterface

public final class BibleReadingPlanHomeReactor: Reactor {
  public enum Action {
    case viewWillAppear
  }
  
  public enum Mutation {
    case currentReadChaptersSet(Int)
  }
  
  public struct State {
    var currentReadChapters: Int = 0
  }
  
  // MARK: - Properties
  public var initialState: State = State()
  
  public var dailyReadingUseCase: DailyBibleReadingChecklistUseCase
  
  public let totalChapters: Int = BibleBook.allChapters
  
  // MARK: - Lifecycle
  public init(dailyReadingUseCase: DailyBibleReadingChecklistUseCase) {
    self.dailyReadingUseCase = dailyReadingUseCase
  }
  
  // MARK: - Helpers
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewWillAppear:
      return Observable.create { [weak self] observer in
        self?.dailyReadingUseCase.fetchTotalReadChapters { result in
          switch result {
          case .success(let success):
            print(success)
            observer.onNext(.currentReadChaptersSet(success))
            observer.onCompleted()
          case .failure(let failure):
            observer.onError(failure)
          }
        }
        return Disposables.create()
      }
    }
  }
  
  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .currentReadChaptersSet(let readChapters):
      newState.currentReadChapters = readChapters
    }
    return newState
  }
}
