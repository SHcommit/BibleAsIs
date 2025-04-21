#  바이블 컨텐트 Feature

- Entry point

1. BibleHome에서 사용자가 Book, chapter를 클릭해서 들어온다.
  이 경우 앞 뒤 자유롭게 이동해 prev, cur, next chapter 컨텐츠(verses)를 볼 수 있다.
  
2. 제약된 페이지를 보는 경우
  - 이 경우는 제약된 페이지다. 한장 또는 n 장 까지만 한정적으로 보여져야 한다.
  
  - 그렇다면 시작 [Book Chapter, 끝 Book Chapter] 이렇게 배열로 받자.
  - + isRestrictEntry
  
---

isRestrictEntry여부에 따라서 마음껏 이전, 다음을 볼 수 있는지 아닐 경우 배열을 통해서 받자! 
끝!

---

BiblePaginationController에서 이제 entry point(init 시점) 가 중요함

> Case 1. `BibleHomePage` 에 의한 진입일  수 있음
> Case 2. `FeedPage`에 의한 진입일 수 있음
> Case 3. `MccCheyne`이나 추후 추가될 다양한 미션에 의한 진입일 수 있음


```
public init(
  currentReadingEntryItem: BibleReadingEntryItem,
  bibleReadingEntryItemsForRange: [BibleReadingEntryItem],
  isRestrictEntry: Bool
) {
```

- isRestrictEntry == true인 경우, bibleReadingEntryItemsForRange에는 읽어야 할
    시작, 끝값을 가져오기 이 때 시작 값을 currentReadingEntryItem 치환 똑같이하기
- isRestrictEntry == false인 경우 bibleReadingEntryITemsForRange = [] 보내주기
- isRestrictEntry값을 넣은 이유는 그래도 가독성있기 때문임. bibleReadingEntryItemsForRange.isEmpty가 대체 가능하긴한대 의미가 모호함.

---

# BibleSleepAudioPlayer

tts를 사용하기 위해선 Info.plist에 권한 추가를 해야함.
마이크, 텍스트를 음성으로 변환.
<key>NSSpeechRecognitionUsageDescription</key>
<string>앱에서 텍스트를 음성으로 변환해 수면 타이머가 작동할 때 오디오로 성경 구절을 읽기 위해 사용됩니다.</string>

<key>NSMicrophoneUsageDescription</key>
<string>음성 인식을 사용하려면 마이크 접근이 필요합니다.</string>
