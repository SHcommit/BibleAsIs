//
//  DefaultRecentBibleBookclipUseCase.swift
//  Domain
//
//  Created by 양승현 on 3/19/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation
import DomainEntity
import DomainInterface

public final class DefaultRecentBibleBookclipUseCase: RecentBibleBookclipUseCase {
  // MARK: - Dependencies
  private let recentBookclipRepository: RecentBibleBookclipRepository
  
  private let bibleRepository: BibleRepository
  
  // MARK: - Lifecycle
  public init(
    recentBookclipRepository: RecentBibleBookclipRepository,
    bibleRepository: BibleRepository
  ) {
    self.recentBookclipRepository = recentBookclipRepository
    self.bibleRepository = bibleRepository
  }
  
  // MARK: - Helpers
  public func saveRecentClip(_ clip: DomainEntity.RecentBibleClip) {
    recentBookclipRepository.saveRecentClip(clip)
  }
  
  public func fetchRecentClip() -> DomainEntity.RecentBibleClip {
    recentBookclipRepository.fetchRecentClip()
  }
  
  public func calculateRecentBibleReadBookChapterPercentage() -> RecentlyReadChapterPercentage {
    let recentBookclip = recentBookclipRepository.fetchRecentClip()
    let contentSizeHeight = recentBookclip.contentSizeHeight
    let offsetY = recentBookclip.offsetY
    var visibleSizeHeight = recentBookclip.visibleSizeHeight
    
    guard contentSizeHeight > 0 else { return 0.0 }
    
    visibleSizeHeight = min(visibleSizeHeight, contentSizeHeight)
    
    let estimatedReadY = min(contentSizeHeight, offsetY + (visibleSizeHeight / 2))
    let progress = estimatedReadY / contentSizeHeight
    return min(100.0, max(1.0, progress * 100.0))
  }
  
  /// 최근 본 화면 절반위치의 verses 2~3개 받아옴
  public func estimatedVisibleVerses(
    _ recentBibleClip: RecentBibleClip,
    completion: @escaping (Result<[BibleVerse], Error>) -> Void
  ) {
    let recentBookclip = recentBookclipRepository.fetchRecentClip()
    
    bibleRepository.fetchBibleVerses(
      for: recentBookclip.book,
      chapter: recentBookclip.chapter) { result in
        switch result {
        case .success(let bibleVerses):
          let numberOfVerses = bibleVerses.count
          guard numberOfVerses > 0 else {
            completion(.failure(CommonError.noDataFound))
            return
          }
          if recentBibleClip.offsetY == 0 {
            completion(.success(bibleVerses))
            return
          }
          /// 확실하게 사용자가 체크한게 아니라서 .. 내가 저장한거라 어림잡아 절반정도로 !
          let centerY = recentBookclip.offsetY + (recentBookclip.visibleSizeHeight / 2.0)
          
          if centerY >= recentBookclip.contentSizeHeight {
            if bibleVerses.count >= 3 {
              let lastIdx = bibleVerses.count - 1
              
              completion(.success([bibleVerses[lastIdx-1], bibleVerses[lastIdx]]))
            } else {
              completion(.success(bibleVerses))
            }
            return
          }
          
          let versePos = (centerY / recentBookclip.contentSizeHeight) * CGFloat(numberOfVerses)
          
          let currentVerse = max(1, min(numberOfVerses, Int(versePos.rounded())))
          guard numberOfVerses > 2 else {
            completion(.success(bibleVerses))
            return
          }
          
          /// verse는 1부터 시작함 index가아님
          var verseRange: [Int] = [currentVerse]
          if currentVerse > 1 { verseRange.insert(currentVerse - 1, at: 0) }
          if currentVerse < numberOfVerses { verseRange.append(currentVerse + 1) }
          
          let filteredVerses = bibleVerses.filter { verseRange.contains($0.verse) }
          completion(.success(filteredVerses))
          
        case .failure(let failure):
          completion(.failure(failure))
        }
      }
  }
}
