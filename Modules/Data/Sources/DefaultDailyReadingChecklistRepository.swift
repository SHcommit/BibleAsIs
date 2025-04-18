//
//  DefaultDailyReadingChecklistRepository.swift
//  Data
//
//  Created by 양승현 on 3/3/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import BibleInterface
import DomainInterface

public final class DefaultDailyReadingChecklistRepository: DailyReadingChecklistRepository {
  // MARK: - Properties
  private let backgroundQueue = DispatchQueue(
    label: "com.bible.dailyReadingChecklistRepository.queue",
    qos: .userInteractive)
  
  private let bibleReadingChecklistDAO: DailyBibleReadingChecklistDAO
  
  // MARK: - Lifecycle
  public init(bibleReadingChecklistDAO: DailyBibleReadingChecklistDAO) {
    self.bibleReadingChecklistDAO = bibleReadingChecklistDAO
  }
  
  // MARK: - Helpers
  public func fetchAlreadyReadEntries(
    book: BibleBook,
    completion: @escaping (Result<[DailyBibleReadingChapterEntry], any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleReadingChecklistDAO.fetchCheckedEntries(book: book) { res in
        completion(.success(res))
      }
    }
  }
  
  /// insert 쓰자! 업데이트는 디비에 값 없을 경우 안넣음
  public func update(
    _ entry: DailyBibleReadingChapterEntry,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      bibleReadingChecklistDAO.update(entry)
      completion(.success(()))
    }
  }
  
  public func insert(
    _ entry: DailyBibleReadingChapterEntry,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    backgroundQueue.async { [weak self] in
      guard let self else { completion(.failure(CommonError.referenceDeallocated)); return }
      // 이거는 이제!! update대용으로 쓰기로함
      // guard entry.alreadyRead else { assertionFailure("값을 저장 할 때는 반드시 읽음 체크가 되야합니다."); return; }
      bibleReadingChecklistDAO.insert(entry)
      completion(.success(()))
    }
  }
}
