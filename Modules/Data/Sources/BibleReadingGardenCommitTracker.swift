//
//  BibleReadingGardenCommitTracker.swift
//  Core
//
//  Created by 양승현 on 2/3/25.
//

import Foundation
import DomainEntity
import CoreInterface
import BibleInterface
import DomainInterface

/// 내부적으로 캐싱하려고했는데 동기화가 중요함
/// 사용자가 나갔다가 이틀 뒤에 접속하면 그것도 파악해서 Entry를 새로 갱신해야함
public final class BibleReadingGardenCommitTracker: BibleReadingGardenTrackable {
  // MARK: - Properties
  private let calendarService: CalendarServiceProtocol
  
  private let readingGardenCommitDAO: BibleReadingGardenCommitDAO
  
//  private var currentEntry: BibleDailyReadingEntry?
  
  // MARK: - Lifecycle
  public init(
    calendarService: CalendarServiceProtocol,
    readingGardenCommitDAO: BibleReadingGardenCommitDAO
  ) {
    self.readingGardenCommitDAO = readingGardenCommitDAO
    self.calendarService = calendarService
//    currentEntry = fetchTodayReadingEntry()
  }
  
  // MARK: - Helpers
  public func increaseForTodayReadingChapters() {
    // MARK: - 새로운 로직
    fetchTodayReadingEntry { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(var currentEntry):
        currentEntry.numberOfReadingChapters += 1
        readingGardenCommitDAO.updateBibleDailyReadingEntry(currentEntry, completion: { })
      case .failure(let failure):
        assertionFailure(failure.localizedDescription)
      }
    }    
    // MARK: - 기존 로직
//    if currentEntry == nil {
//      var newEntry = makeCurrentEntry()
//      newEntry.numberOfReadingChapters += 1
//      currentEntry = newEntry
//      readingGardenDAO.saveBibleDailyReadingEntry(newEntry)
//      return
//    }
//    
//    /// 함수 호출시점이 기존 currentEntry가 어제 날짜가 되버린 경우
//    if isCurrentEntryOutdated() {
//      readingGardenDAO.updateBibleDailyReadingEntry(currentEntry!)
//      var newEntry = makeCurrentEntry()
//      newEntry.numberOfReadingChapters += 1
//      self.currentEntry = newEntry
//      readingGardenDAO.saveBibleDailyReadingEntry(newEntry)
//      return
//    }
//    
//    self.currentEntry?.numberOfReadingChapters += 1
//    readingGardenDAO.updateBibleDailyReadingEntry(currentEntry!)
  }
  
  // 만약에 삭제할때는 이제, 오늘 삭제할게 없는거로.
  // 오늘 삭제할거를 받아온담에말이지 오늘 entry가 없다면 새로운 엔트리 생성하구.
  public func decreaseForTodayReadingChapters() {
    fetchTodayReadingEntry { [weak self] result in
      guard let self else { assertionFailure("왜 self 가 없을까?"); return }
      switch result {
      case .success(var currentEntry):
        if currentEntry.numberOfReadingChapters <= 0 { return }
        currentEntry.numberOfReadingChapters -= 1
        readingGardenCommitDAO.updateBibleDailyReadingEntry(currentEntry, completion: { })
        return
      case .failure(let failure):
        assertionFailure(failure.localizedDescription)
        return
      }
      
    }
//    if currentEntry.numberOfReadingChapters <= 0 { return }
//    currentEntry.numberOfReadingChapters -= 1
//    readingGardenCommitDAO.updateBibleDailyReadingEntry(currentEntry, completion: { })
//    return
  }
  
// 사용자가 앱을 나갔다가 이일 뒤에 들어온 경우 등등
//  public func checkIfCurrentEntryIsOutdated() {
//    if isCurrentEntryOutdated() {
//      readingGardenDAO.updateBibleDailyReadingEntry(currentEntry!)
//      let newEntry = makeCurrentEntry()
//      currentEntry = newEntry
//      readingGardenDAO.saveBibleDailyReadingEntry(newEntry)
//    }
//  }
  
  public func fetchTodayReadingEntry(completion: @escaping (Result<BibleDailyReadingEntry, any Error>) -> Void) {
    let today = calendarService.getTodayComponents()
    
    readingGardenCommitDAO.fetchBibleDailyReadingEntry(
      forYear: today.year!, month: today.month!, day: today.day!, completion: { [weak self] dailyReadingEntry in
        guard let self else { return }
        if let dailyReadingEntry {
          completion(.success(dailyReadingEntry))
        } else {
          /// 데이터가 없다면 새로 만들기
          let entry = makeCurrentEntry()
          readingGardenCommitDAO.saveBibleDailyReadingEntry(entry) {
            completion(.success(entry))
          }
        }
      })

//    if let entry = readingGardenCommitDAO.fetchBibleDailyReadingEntry(
//      forYear: today.year!,
//      month: today.month!,
//      day: today.day!, completion: <#(BibleDailyReadingEntry?) -> Void#>
//    ) {
//      return entry
//    }
//    
//    /// 데이터 새로 만들어야함
//    let entry = makeCurrentEntry()
//    readingGardenCommitDAO.saveBibleDailyReadingEntry(entry)
//    return entry
  }
  
  private func makeCurrentEntry() -> BibleDailyReadingEntry {
    let today = calendarService.getTodayComponents()
    return .init(
      year: today.year!, month: today.month!, day: today.day!, numberOfReadingChapters: 0)
  }
}
