#  BibleReadingPlan

### 주의해야 할 사항.

디비에 MccCheyne reading plan 최소 challenge day는 1임.

그래서 BibleReadingPlanReactor.State 보면, currentDay, selectedDay가 있는데, 전부 Day 1부터 시작함.
반면 reusable view에서 사용되는 indexPath에 들어갈 때는 -1을 해줘야함.

그래서  `currentDayIndex()`, `selectedDayIndex()` 이들은 직접적으로 컬랙션 뷰 DataSource, Delegate에 
관여해서 -1씩 해줘야 함. 

그러나 내부에 동작하는 프로그래스 바(진행 상태)를 위해서는 Day를 표시해주어야 하기에 +1 해줘야 함.

- 이 Feature는 다른 곳에서 뷰로 쓰일 수도 있음 : ) 
