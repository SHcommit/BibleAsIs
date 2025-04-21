//
//  BibleSleepAudioPlayerProtocol.swift
//  CoreInterface
//
//  Created by 양승현 on 3/16/25.
//

import DomainEntity
import Foundation

public protocol BibleSleepAudioPlayerProtocol: AnyObject {
  // 지금까지 진행된 시간
  typealias ElapsedExecutingTime = TimeInterval
  
  typealias PrograssValue = Double
  
  /// 현재 오디오 일시정지
  func pause()
  
  /// 다시 재생
  func resume()
  
  /// 다음 구절 재생
  func nextVerse()
  
  /// 이전 구절 재생
  func prevVerse()
  
  /// 이전 또는 다음 챕터로 가기위해 오디오 모든거 종료하는 함수
  func releaseAllAudio()
  
  /// 지금까지 진행했던 elapsedSec받기
  var elapsedSeconds: TimeInterval { get }
  
  /// 오디오 설정 초기화
  func configure(totalDuration: TimeInterval)
  
  /// 진행 상태 업데이트 (진행 중인 시간)
  var onProgressUpdate: ((ElapsedExecutingTime) -> Void)? { get set }
  
  /// 특정한 book이 끝났을 때 호출됨 (다음 챕터가 있는지 확인 후 재생 여부 결정)
  var specificBookHasAllCompleted: ((ElapsedExecutingTime) -> Void)? { get set }
  
  /// 사용자가 이전 챕터를 요청함.
  var prevChapterInvaild: ((ElapsedExecutingTime) -> Void)? { get set }
  
  /// 지정된 시간 지났음
  var sleepTimerDidEnd: (() -> Void)? { get set }
}
