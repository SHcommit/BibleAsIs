//
//  BibleHighlightHistoryReactor.swift
//  MyActivityFeature
//
//  Created by 양승현 on 2/19/25.
//

import RxSwift
import ReactorKit
import Foundation
import DomainEntity
import DomainInterface
import DesignSystemItems

public final class BibleHighlightHistoryReactor: Reactor {
  public enum Action {
    case itemsRefresh
  }
  
  public enum Mutation {
    case itemsRefreshed([BiblehighlightHistoryItem])
    case shouldRefresh(Bool)
    case errorOccured(String)
  }
  
  public struct State {
    var hasInitiallyFetched = false
    
    /// 초기에 리엑터 첨 접할 때는 items에 따라서 reactor 바인딩을 했는데, 이게 잠재적으로
    /// 처음엔 무저건 0개 -> 새롭게 데이터 받고 reload해야한느데, 그때도 데이터가 없으면 0개. 그러면 리엑터 바인딩 안먹힘 여전히 0이어서 (변화x)
    /// 그래서 리프래시 목적인 바인딩은 다른거로 해야함
    var items: [BiblehighlightHistoryItem] = []
    
    var shouldRefresh = false
    var unexpecetdOccuredErrorMsg: String = ""
  }
  
  // MARK: - Properties
  public var initialState: State = State()
  
  private let highlightFetchUseCase: BibleHighlightFetchUseCase
  
  private let verseFetchUseCase: BibleVerseFetchUseCase
  
  private let backgroundQueue = DispatchQueue(label: "com.Presentaiton.BibleHighlightReactor.Queue")
  
  // MARK: - Lifecycle
  public init(
    highlightFetchUseCase: BibleHighlightFetchUseCase,
    verseFetchUseCase: BibleVerseFetchUseCase
  ) {
    self.highlightFetchUseCase = highlightFetchUseCase
    self.verseFetchUseCase = verseFetchUseCase
  }
  
  // MARK: - Helpers
  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .itemsRefresh:
#if DEBUG
      //      let items: [BiblehighlightHistoryItem] = BiblehighlightHistoryItem.makeStub()
      //      return .just(Mutation.itemsRefreshed(items))
#endif
      // 깔끔하게 노트는 가져오지말자. 노트기록은 노트 화면에서.
      return Observable.concat([
        fetchAllHighlightsStream(),
        .just(.shouldRefresh(true)),
        .just(.shouldRefresh(false))
      ])
    }
  }
  
  private func fetchAllHighlightsStream() -> Observable<Mutation> {
    fetchAllHighlights().flatMap { [weak self] highlightList -> Observable<Mutation> in
      guard let self else {
        return Observable.concat([
          .just(Mutation.errorOccured(CommonError.referenceDeallocated.localizedDescription)),
          .just(Mutation.errorOccured(""))
        ])
      }
      
      /// 이제 하이라이트 맨 처음 원소들로 verseId를 통해 verse 정보 가져오자.
      /// highlightList는 각 일차원배열은 특정한 verseId에 대한 highlights임.
      /// firstHighlights, verses는 1대1 대응
      let firstHighlights = highlightList.compactMap { $0.first }
      var verses: [BibleVerse] = []
      var errorOccuredIndexList: [Int] = []
      
      return Observable.create { [weak self] verseObserver in
        guard let self else {
          verseObserver.onError(CommonError.referenceDeallocated); return Disposables.create()
        }
        let group = DispatchGroup()
        
        for (index, highlight) in firstHighlights.enumerated() {
          group.enter()
          verseFetchUseCase.fetchBibleVerse(byVerseId: highlight.verseId) { result in
            switch result {
            case .success(let fetchedVerse):
              if let fetchedVerse {
                verses.append(fetchedVerse)
              } else {
                errorOccuredIndexList.append(index)
              }
            case .failure(let failure):
              errorOccuredIndexList.append(index)
              assertionFailure("모든 하이라이트 받는 중에 에러발생: \(failure.localizedDescription)")
            }
            group.leave()
          }
        }
        
        group.notify(queue: backgroundQueue) {
          var bibleHighlightHistoryItems: [BiblehighlightHistoryItem] = []
          for (index, highlights) in highlightList.enumerated() {
            /// 에러발생한거 제외
            if errorOccuredIndexList.contains(index) { continue }
            let verseId = firstHighlights[index].verseId
            guard let verseIndex = verses.firstIndex(where: { $0.id == verseId}) else { continue }
            let verse = verses[verseIndex]
            let highlightItems = highlights.map {
              if HighlightColorIndex(rawValue: $0.colorIndex) == nil {
                assertionFailure("hexColor -> ColorIndex로 바꿔서 다크모드에도 대응하게바꿨는데 hexColor로 입력됬나봄. \($0)")
              }
              return BibleVerseHighlightItem(
                id: $0.id, range: $0.range,
                colorIndex: .init(rawValue: $0.colorIndex) ?? .blue)
            }
            let highlightHistoryItem = BiblehighlightHistoryItem(
              reference: .init(book: verse.book, chapter: verse.chapter, verse: verse.verse),
              verseContent: verse.content,
              highlights: highlightItems)
            bibleHighlightHistoryItems.append(highlightHistoryItem)
          }
          
          verseObserver.onNext(bibleHighlightHistoryItems)
          verseObserver.onCompleted()
        }
        return Disposables.create()
      }.map { Mutation.itemsRefreshed($0) }
    }
  }
  
  // MARK: - Reduce
  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .itemsRefreshed(let items):
      newState.items = items
      if !newState.hasInitiallyFetched {
        newState.hasInitiallyFetched = true
      }
    case .errorOccured(let error):
      newState.unexpecetdOccuredErrorMsg = error
      if !newState.hasInitiallyFetched, error.count > 0 {
        newState.hasInitiallyFetched = true
      }
    case .shouldRefresh(let shouldRefresh):
      newState.shouldRefresh = shouldRefresh
    }
    return newState
  }
  
  // MARK: - Helpers
  private func fetchAllHighlights() -> Observable<[[BibleHighlight]]> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      highlightFetchUseCase.fetchAllHighlights { result in
        switch result {
        case .success(let success):
          observer.onNext(success)
          observer.onCompleted()
        case .failure(let failure):
          observer.onError(failure)
        }
      }
      return Disposables.create()
    }
  }
}

// MARK: - BibleHighlightHistoryAdapterDataSource
extension BibleHighlightHistoryReactor: BibleHighlightHistoryAdapterDataSource {
  var numberOfItmes: Int {
    currentState.items.count
  }
  
  func item(_ row: Int) -> BiblehighlightHistoryItem {
    currentState.items[row]
  }
  
  var hasInitiallyFetched: Bool {
    currentState.hasInitiallyFetched
  }
}
