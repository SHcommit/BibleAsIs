//

import Foundation
import AVFoundation
import DomainEntity
import CoreInterface

/// BibleSleepAudioPlayer
///
/// Notes:
/// 1. 사용자가 바이블 컨텐츠 화면을 나가면 제거하는 거로 하자.
/// 2. 추후에 시간나면 뭐 터치방지? 같은거도
/// 3. 데이터소스는 외부에서 계속 지속해주어야 함. 이건 fetchNextVerse를 시간의 흐름에 따라서 호출해줌.
///
/// 3. setCateogry .playback하면 무음모드에서 안됨,,,
///   playback으로 해야함.
public final class BibleSleepAudioPlayer: NSObject, BibleSleepAudioPlayerProtocol {
  // MARK: - Properties
  public var elapsedSeconds: TimeInterval {
    _elapsedSeconds
  }
  
  private var synthesizer = AVSpeechSynthesizer()
  
  private let dataSource: BibleSleepAudioPlayDataSource
  
  private var session: AVAudioSession
  
  /// 누적 지금까지 진행된 시간
  private var _elapsedSeconds = 0.0
  
  private var totalDuration = 0.0
  
  /// 진행중 타이머
  private var progressTimer: Timer?
  
  private var sleepTimerTask: DispatchWorkItem?
  
  private var isPaused = true
  
  public var onProgressUpdate: ((ElapsedExecutingTime) -> Void)?
  
  /// 특정한 book이 전부 완료됨을 외부에 보냄
  /// 관리자는 book의 다음 챕터가 있는지 확인하고, 다음 챕터를 틀어주어야 함.
  /// 그 전까지는 여기서 퍼즈를 걸었음으로 데이터소스가 제공 가능하게 된다면 다시 Resume해주어야 한다. 뀨!
  public var specificBookHasAllCompleted: ((ElapsedExecutingTime) -> Void)?
  
  /// 사용자가 이전 챕터를 요청함.
  public var prevChapterInvaild: ((ElapsedExecutingTime) -> Void)?
  
  /// 지정된 시간 지남
  public var sleepTimerDidEnd: (() -> Void)?
  
  // MARK: - Lifecycle
  public init(dataSource: BibleSleepAudioPlayDataSource) {
    session = AVAudioSession.sharedInstance()
    self.dataSource = dataSource
    super.init()
    synthesizer.delegate = self
    do {
      try session.setCategory(.soloAmbient, mode: .default)
      try session.setActive(true)
    } catch {
      print("audioSession properties weren't set because of an error.")
    }
  }
  
  deinit {
    print("\(Self.self) 메모리 반납 해요~")
  }
  
  // MARK: - Public Helpers
  /// 최초 구절 or 타이머 입력하고 시작하는 거!
  /// 구절 새로운거 클릭할 때마다 전부 초기화
  /// 타이머 입력할 때마다 전부 초기화
  /// configure 호출 후
  /// resume 으로 시작
  public func configure(totalDuration totaldDration: TimeInterval = 600) {
    self.totalDuration = totaldDration
    _elapsedSeconds = 0
    isPaused = true
  }
  
  /// 진행중인 시작도 일시 중지됨
  public func pause() {
    // 현재까지 진행된 시간을 갱신 해보도록 하자! (현재 시간 - 시작 시간)
    if let progressTimer = progressTimer {
      _elapsedSeconds += progressTimer.timeInterval
    }
    
    synthesizer.stopSpeaking(at: .immediate)
    isPaused = true
    stopTimer()
  }
  
  /// 타이머 종료됬니?
  public func hasTimerExpired() -> Bool {
    return _elapsedSeconds >= totalDuration
  }
  
  /// 시자그!
  public func resume() {
    if hasTimerExpired() {
      isPaused = true
      pause()
      sleepTimerDidEnd?()
      return
    }
    
    guard let currentVerse = dataSource.fetchCurrentVerse() else {
      isPaused = true
      pause()
      assertionFailure("반드시 reactor에서 데이터를 받아온 후에 이제 sleep audio player를 활성화 시켜야한다. 그렇지 않으면 오디오 실행안됨")
      return
    }
    
    guard isPaused else { return }
    isPaused = false
    startTimer()
    speak(with: currentVerse.content)
    scheduleSleepTimer()
  }
  
  public func releaseAllAudio() {
    synthesizer.stopSpeaking(at: .immediate)
    pause()
  }
  
  public func nextVerse() {
    if hasTimerExpired() {
      isPaused = true
      pause()
      sleepTimerDidEnd?()
      return
    }
    
    guard let nextVerse = dataSource.fetchNextVerse() else {
      isPaused = true
      pause()
      releaseAllAudio()
      specificBookHasAllCompleted?(_elapsedSeconds)
      print("다음 벌스 못찾음.")
      print("뀨뀨꺄꺄")
      
      return
    }
    
    if isPaused {
      isPaused = false
      scheduleSleepTimer()
    }
    synthesizer.stopSpeaking(at: .immediate)
    speak(with: nextVerse.content)
  }
  
  public func prevVerse() {
    if hasTimerExpired() {
      isPaused = true
      pause()
      sleepTimerDidEnd?()
      return
    }
    
    if isPaused {
      isPaused = false
      scheduleSleepTimer()
    }
    
    guard let prevVerse = dataSource.fetchPrevVerse() else {
      isPaused = true
      pause()
      releaseAllAudio()
      prevChapterInvaild?(_elapsedSeconds)
      return
    }
    synthesizer.stopSpeaking(at: .immediate)
    speak(with: prevVerse.content)
  }
  
  // MARK: - Private Helpers
  private func scheduleSleepTimer() {
    let remainingTime = totalDuration - TimeInterval(_elapsedSeconds)
    guard remainingTime > 0 else {
      pause()
      sleepTimerDidEnd?()
      return
    }
    sleepTimerTask = DispatchWorkItem { [weak self] in
      self?.synthesizer.stopSpeaking(at: .immediate)
      self?.progressTimer = nil
      self?._elapsedSeconds = self?.totalDuration ?? 0.0
      self?.sleepTimerDidEnd?()
    }
    
    if let sleepTimerTask {
      DispatchQueue.main.asyncAfter(deadline: .now() + remainingTime, execute: sleepTimerTask)
    }
  }

  private func speak(with verse: String) {
//    startTimer()
    synthesizer.stopSpeaking(at: .immediate)
    
    let utterance = AVSpeechUtterance(string: verse)
    utterance.preUtteranceDelay = 0.3
    if let koreanFemaleVoice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Yuna-compact") {
      utterance.voice = koreanFemaleVoice
    } else {
      utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
    }
    
    utterance.rate = 0.45
    utterance.volume = 1
    utterance.pitchMultiplier = 0.78
    utterance.postUtteranceDelay = 0.3
    synthesizer.speak(utterance)
  }
  
  private func startTimer() {
    synthesizer.stopSpeaking(at: .immediate)
    progressTimer?.invalidate()
    progressTimer = Timer.scheduledTimer(
      withTimeInterval: 1.0,
      repeats: true,
      block: { [weak self] _ in
        guard let self else { return }
        if !self.isPaused {
          _elapsedSeconds += 1
          let remainingTime = totalDuration - TimeInterval(_elapsedSeconds)
          onProgressUpdate?(remainingTime)
        }
      })
  }

  private func stopTimer() {
    progressTimer?.invalidate()
    progressTimer = nil
    sleepTimerTask?.cancel()
    sleepTimerTask = nil
  }
}

// MARK: - AVSpeechSynthesizerDelegate
extension BibleSleepAudioPlayer: AVSpeechSynthesizerDelegate {
  public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    
    nextVerse()
//    guard let nextVerse = dataSource.fetchNextVerse() else {
//      pause()
//      specificBookHasAllCompleted?(_elapsedSeconds)
//      print("모든거 다끝남")
//      return
//    }
//    speak(with: nextVerse.content)
  }
  
  public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
    print("DEBUG - Started speaking: \(utterance.speechString)")
  }
}
