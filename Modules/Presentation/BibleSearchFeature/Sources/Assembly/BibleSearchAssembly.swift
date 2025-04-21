//
//  BibleSearchAssembly.swift
//  BibleSearchFeature
//
//  Created by 양승현 on 3/25/25.
//

import UIKit
import Common
import Swinject
import ReactorKit
import DomainEntity
import DomainInterface
import DesignSystemItems
import BibleSearchInterface

public struct BibleSearchAssembly: Swinject.Assembly {
  public init() { }
  
  public func assemble(container: Container) {
    // MARK: - Search result
    container.register((any Reactor).self, name: BibleSearchResultReactor._identifier) { r in
      guard let searchQueryFetchRepository = r.resolve(BibleSearchQueryFetchRepository.self) else {
        fatalError("바이블 서치 쿼리 레포지토리 의존성 등록 안하거나 Assembly 되지 않음")
      }
      guard let searchHistoryUseCase = r.resolve(BibleSearchHistoryUseCase.self) else {
        fatalError("BibleSearchHistoryUseCase 의존성 등록 안하거나 Assembly 되지 않음")
      }
      guard let recentlySearchedQueryRepository = r.resolve(BibleRecentlySearchedQueryRepository.self) else {
        fatalError("BibleRecentlySearchedQueryRepository 의존성 등록 안하거나 Assembly 되지 않음")
      }
      
      return BibleSearchResultReactor(
        searchQueryFetchRepository: searchQueryFetchRepository,
        bibleSearchHistoryUseCase: searchHistoryUseCase,
        bibleRecentlySearchedQueryRepository: recentlySearchedQueryRepository)
    }
    
    container.register(
      UIViewController.self,
      name: BibleSearchResultViewController._identifier
    ) { (r, flowDependencies: BibleSearchCoordinator) in
      guard let bibleSearchResultReactor = r.resolve(
        (any Reactor).self,
        name: BibleSearchResultReactor._identifier
      ) as? BibleSearchResultReactor else {
        fatalError("BibleSearchResultReactor 의존성 등록 안됨. 확인 바람")
      }
      let bibleSearchResultVC = BibleSearchResultViewController()
      bibleSearchResultVC.reactor = bibleSearchResultReactor
      bibleSearchResultVC.showBibleReadingPage = { bibleVerseItem in
        let isOldTestament = bibleVerseItem.reference.book.isOldTestament
        flowDependencies.showBibleReadingPage(
          testament: .init(isOldTestament: isOldTestament),
          book: bibleVerseItem.reference.book,
          chapter: bibleVerseItem.reference.chapter)
      }
      return bibleSearchResultVC
    }
    
    // MARK: - Search
    container.register((any Reactor).self, name: BibleSearchReactor._identifier) { r in
      guard let recentlySearchedRepository = r.resolve(BibleRecentlySearchedQueryRepository.self) else {
        fatalError("BibleRecentlySearchedQueryRepository 등록 안됬거나 Assembly 안됨")
      }
      guard let searchHistoryUseCase = r.resolve(BibleSearchHistoryUseCase.self) else {
        fatalError("BibleSearchHistoryUseCase 등록 안됬거나 Assembly 안됨")
      }
      
      // 테스트 용으로 가능함 ㅇㅅㅇ
//      return BibleSearchReactor(
//        recentlySearchedRepository: StubBibleRecentlySearchedQueryRepository(),
//        searchHistoryUseCase: StubBibleSearchHistoryUseCase())
      
      return BibleSearchReactor(
        recentlySearchedRepository: recentlySearchedRepository,
        searchHistoryUseCase: searchHistoryUseCase)
    }
    
    container.register(
      UIViewController.self,
      name: BibleSearchViewController._identifier
    ) { (r, flowDependencies: BibleSearchCoordinator) in
      guard let bibleSearchReactor = r.resolve((any Reactor).self, name: BibleSearchReactor._identifier) as? BibleSearchReactor else {
        fatalError("BibleSearchReactor 등록 안됨")
      }
      
      let bibleSearchViewController = BibleSearchViewController(flowDependencies: flowDependencies)
      bibleSearchViewController.reactor = bibleSearchReactor
      return bibleSearchViewController
    }
    
    container.register(BibleSearchInterface.self) { _ in
      return BibleSearchGateway()
    }
  }
}
