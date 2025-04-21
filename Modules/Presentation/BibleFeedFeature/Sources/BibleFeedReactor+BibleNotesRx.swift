//
//  BibleFeedReactor+BibleNotesRx.swift
//  BibleFeedFeature
//
//  Created by 양승현 on 3/19/25.
//

import RxSwift
import ReactorKit
import Foundation
import DomainEntity

/// Notes:
///   - 피드에서는 totalNotes가 필요 없음.
///     피드에서 보여지는 노트는 최대 3개 이므로.
///     페이징 지원을 안함.
extension BibleFeedReactor {
  /// 노트는 항상 최신 노트만 가져오긔
  private static let notePage = 1
  /// 노트 가져오는 개수는 3개 고정.
  private static let noteOffset = 3
  
  // MARK: - AsObservable
  private func fetchNotesAsObservable(page: Int, pageSize: Int) -> Observable<(notes: [BibleNote], totalNotes: Int)> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      bibleNoteUseCase.fetchNotes(page: page, pageSize: pageSize) { result in
        switch result {
        case .success(let entry):
          observer.onNext(entry)
          observer.onCompleted()
        case .failure(let error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
  
  private func fetchBibleVersesAsObservable(forReferences refs: [BibleReference]) -> Observable<[BibleVerse]> {
    return Observable.create { [weak self] observer in
      guard let self else { observer.onError(CommonError.referenceDeallocated); return Disposables.create() }
      bibleVerseFetchUseCase.fetchBibleVerses(forReferences: refs) { result in
        switch result {
        case .success(let entry):
          observer.onNext(entry)
          observer.onCompleted()
        case .failure(let error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
  
  // MARK: - Stream
  func _fetchNotesBaseStream() -> Observable<Mutation> {
    return fetchNotesAsObservable(page: Self.notePage, pageSize: Self.noteOffset)
      .flatMap { [weak self] (notes: [BibleNote], _) in
        guard let self else {
          return Observable.just(
            Mutation.unexpetedErrorMessageOccured(CommonError.referenceDeallocated.localizedDescription))
        }
        
        let bibleRefs = notes.compactMap { note -> BibleReference? in
          guard let bibleRef = BibleReference(bibleReferenceId: note.verseId) else {
            assertionFailure("이거 절대 오류가 날 수 없는거임 해당 id 확인바람: \(note.verseId)"); return nil
          }
          return bibleRef
        }
        
        /// 여기서 필터링 해주자. 노트 3 개이상이면 3개만 가져오기! 최대 3개
        /// 근데 이미 디비에 쿼리할 때 offset 3 으로해서 3개만 가져올것이야.
        return fetchBibleVersesAsObservable(forReferences: bibleRefs)
          .map { fetchedVerses in
            if fetchedVerses.isEmpty {
              return Mutation.notesFetched(versesForNote: [], notes: [])
            }
            
            let maxCnt = fetchedVerses.count >= 3 ? 3 : fetchedVerses.count
            
            let filteredVerses: [BibleVerse] = (0..<maxCnt).map { fetchedVerses[$0] }
            let filteredNotes: [BibleNote] = (0..<maxCnt).map { notes[$0] }
            return Mutation.notesFetched(versesForNote: filteredVerses, notes: filteredNotes)
          }
      }
  }
  
  /// 현재 개발적으로 특정 섹션만 리로드하는 로직 사용x.
  /// 그러나 처음에 lazy loading으로 이 섹션 fetch 하는 용도일 땐 사용.
  func fetchNotesStream(forNewSection: Bool) -> Observable<Mutation> {
    if forNewSection {
      return Observable.concat([
        .just(.isLoadingForNewSectionSet(true)),
        _fetchNotesBaseStream()
          .delay(.milliseconds(Int.random(in: 250...470)), scheduler: MainScheduler.instance),
        .just(Mutation.notesFetchedCompletion(true)),
        .just(Mutation.notesFetchedCompletion(false)),
        .just(.isLoadingForNewSectionSet(false)).delay(.milliseconds(77), scheduler: MainScheduler.instance)
      ])
    }
    
    return Observable.concat([
      _fetchNotesBaseStream(),
      .just(Mutation.notesFetchedCompletion(true)),
      .just(Mutation.notesFetchedCompletion(false))
    ])
  }
}
