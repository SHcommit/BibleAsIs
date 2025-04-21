//
//  BibleReedReactor+RecentBibleBookclipRx.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 3/19/25.
//

import RxSwift
import ReactorKit
import Foundation
import DomainEntity
import DesignSystemItems

extension BibleFeedReactor {
  // MARK: - AsObservable
  private func fetchRecentBibleBookclipAsObservable() -> Observable<RecentReadBibleBookclipItem> {
    let readPercentage = recentBibleBookclipUseCase.calculateRecentBibleReadBookChapterPercentage()
    let recentClip = recentBibleBookclipUseCase.fetchRecentClip()
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      recentBibleBookclipUseCase.estimatedVisibleVerses(recentClip) { result in
        switch result {
        case .success(let verses):
          let recentReadBibleBookclipItem: RecentReadBibleBookclipItem!
          if verses.isEmpty {
            /// 아마 맨 처음에만 이게 나올 수 있음.
            /// 그러나 이후에도 계쏙해서 이게나온다면 클립받아오는 로직 확인해봐야함.
            let v1 = "태초에 하나님이 천지를 창조하시니라"
            let v2 = "땅이 혼돈하고 공허하며 흑암이 깊음 위에 있고 하나님의 신은 수면에 운행하시니라"
            let v3 = "하나님이 가라사대 빛이 있으라 하시매 빛이 있었고"
            recentReadBibleBookclipItem = RecentReadBibleBookclipItem(
              versesContent: v1 + v2 + v3,
              bibleReference: .init(book: .genesis, chapter: 1, verse: 1),
              currentReadPercentage: 1)
          } else {
            var verses = verses
            if verses.count >= 3 {
              verses = [verses[0], verses[1], verses[2]]
            }
            recentReadBibleBookclipItem = RecentReadBibleBookclipItem(
              versesContent: verses.map { $0.content }.joined(separator: " "),
              bibleReference: verses[0].toBibleReference(),
              currentReadPercentage: readPercentage)
          }
          observer.onNext(recentReadBibleBookclipItem)
          observer.onCompleted()
        case .failure(let error):
          let v1 = "태초에 하나님이 천지를 창조하시니라"
          let v2 = "땅이 혼돈하고 공허하며 흑암이 깊음 위에 있고 하나님의 신은 수면에 운행하시니라"
          let v3 = "하나님이 가라사대 빛이 있으라 하시매 빛이 있었고"
          let recentReadBibleBookclipItem = RecentReadBibleBookclipItem(
            versesContent: v1 + v2 + v3,
            bibleReference: .init(book: .genesis, chapter: 1, verse: 1),
            currentReadPercentage: 1)
          print(error.localizedDescription)
          assertionFailure("에러남. 클립 데이터 없음. 최초 앱 접속 후 컨텐츠 화면 안가서그럼 최소 한번 컨텐츠 화면가면 이 로직 호출되면 안됨.")
          observer.onNext(recentReadBibleBookclipItem)
          observer.onCompleted()
        }
      }
      return Disposables.create()
    }
  }
  
  // MARK: - Stream
  func fetchRecentBibleBookclipBaseStream() -> Observable<Mutation> {
    fetchRecentBibleBookclipAsObservable().map { Mutation.recentBibleBookclipFetched($0) }
  }
  
  // MARK: - Notes
  /// "최근 북 클립 섹션만 업테이트 할 경우 사용됨. 지금은 개별 섹션 업데이트 로직 아직 미사용"
  func fetchRecentBibleBookclipStream() -> Observable<Mutation> {
    return Observable.concat([
      fetchRecentBibleBookclipBaseStream(),
      .just(.recentBibleBookclipFetchedCompletion(true)),
      .just(.recentBibleBookclipFetchedCompletion(false))
    ])
  }
}
