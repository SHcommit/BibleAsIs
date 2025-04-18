//
//  DateHelper.swift
//  Common
//
//  Created by 양승현 on 2/24/25.
//  Copyright © 2025 seunghyun yang. All rights reserved.
//

import Foundation

public final class BibleDateController {
  private init() { }
  public static let shared = BibleDateController()
  
  // MARK: - 디비에 저장할때는 1970년 기준으로 초단위 변환하는게 순서 정렬하기 쉬움
  public var nowBased1970Sec: Double {
    Date().timeIntervalSince1970
  }
  
  // MARK: - yyyy-MM-dd HH:mm:ss
  /// 하.. timezone필수다 진짜루..
  /// 테스트할때 디비에 넣기전에 arrange에서 지정한 시간은 정확한데 이걸 뺄때 -8시간씩 차이가 났음 계속.. 쿼리문젠가 뭐문젠가 파악하다가 타임존 문제였음..ㅠ
  /// 기본 값은 서울로 한다.
  public var yyyyMMdd_hhmmss_dateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    // MARK: - 이걸 설정해야하는걸까? 이거 유닛 테스트할때는 불편했어가지구 서울로했는데..
    dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    return dateFormatter
  }
  
  public func getYYYYmmDD_HHmmSS_String(from date: Date) -> String {
    yyyyMMdd_hhmmss_dateFormatter.string(from: date)
  }
  
  public func getCurDate() -> String {
    return yyyyMMdd_hhmmss_dateFormatter.string(from: Date())
  }
  
  public func toDate(from: String) -> Date? {
    yyyyMMdd_hhmmss_dateFormatter.date(from: from)
  }
  
  /// "2025", "1월 6일" 형식으로 분리
  public func getYearAndFormattedDate(from date: Date) -> (year: String, monthDay: String) {
    let yearFormatter = DateFormatter()
    yearFormatter.dateFormat = "yyyy"
    yearFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "M월 d일"
    dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    
    let year = yearFormatter.string(from: date)
    let formattedDate = dateFormatter.string(from: date)
    
    return (year, formattedDate)
  }
  
  // MARK: - yy-MM-dd
  public var yymmddDateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yy-MM-dd"
    dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    return dateFormatter
  }
  
  public func convertYYMMDDString(from date: Date) -> String {
    return yymmddDateFormatter.string(from: date)
  }
  
  public func toYYmmddDate(from: String) -> Date? {
    yymmddDateFormatter.date(from: from)
  }

}
