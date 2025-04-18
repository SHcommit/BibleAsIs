//
//  BibleReadingReactor+GardenLog.swift
//  BibleContentFeature
//
//  Created by 양승현 on 3/17/25.
//

import RxSwift
import ReactorKit
import Foundation
import DomainEntity
import DesignSystemItems

extension BibleReadingReactor {
  // MARK: - AsObservable
  func saveBibleReadingGardenLogAsObservable() -> Observable<BibleReadingSaveCompletionState> {
    let today = calendarService.getTodayComponents()
    
    /// 읽기 완료는 완료하고 컴플리션 주어야함!
    let newReadingLogEntry = BibleReadingGardenLogEntry(
      year: today.year!, month: today.month!, day: today.day!,
      book: currentReadingEntryItem.bibleBook,
      chapter: currentReadingEntryItem.chapter)
    
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      bibleReadingGardenSaveUseCase.saveBibleReadingGarden(for: newReadingLogEntry) { result in
        switch result {
        case .success:
          observer.onNext(.saved)
          observer.onCompleted()
        case .failure(let error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
  
  // MARK: - Stream
  /// 스트림 끊길거 flatMap에서 새 스트림으로 방출해서 방지.
  /// flatMap 내부에서 뭐 gardenLogAsObservable이 정상적이던 catch던 flatMap이 후 호출해야하는 로직 동일.
  func saveBibleReadingGardenLogStream() -> Observable<Mutation> {
    return .just(.none)
      .flatMap { [weak self] _ -> Observable<Mutation> in
        guard let self else {
          return .just(.error(CommonError.referenceDeallocated.localizedDescription))
        }
        return Observable.concat([
          saveBibleReadingGardenLogAsObservable()
            .map { Mutation.readCompletionSaveStateHandle($0) }
            .catch {
              return Observable.concat([
                .just(Mutation.error($0.localizedDescription)),
                .just(Mutation.error("")),
                .just(Mutation.readCompletionSaveStateHandle(.notSaved))
              ])
            },
          .just(Mutation.readCompletionSaveStateCompletion(true)),
          .just(Mutation.readCompletionSaveStateCompletion(false))
        ])
      }
  }
}
