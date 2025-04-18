## BibleGarden 로직

1. 데이터베이스 통합.
2. 사용자는 앱을 접속할 때 데이터베이스에선 오늘 날짜를 기준으로 BibleDailyReadingEntry를 받아온다.
2-1. entry가 없다면 Tracker를 기반으로 오늘 날짜 + readingChapters = 0 의 entry를 데이터베이스에 넣고 이 정보를 받아온다.
3. 사용자가 어느 방식으로 앱을 종료하거나, 백그라운드로 이동 할 때 등 현재 갖고 있는 정보를 저장한다.
  -> 근데 이 방법보단, 사용자가 특정한 chapter를 읽었을 때마다 그때 그때 증가된 entry를 디비에 반영하도록 하자.
  -> Tracker는 오늘의 데이터를 처음 받을 때마다 flag변수를 통해서 tracker가 갖는 entry가 오늘에 대한 대이터인지 파악하고
  -> readingChapter를 increase하기 전에 현재 날짜와 가지고 있는 entry와의 날짜를 비교해 새로운 날짜라면, 
  -> 새로운 날짜 + readingChapter +1한 정보를 디비에 새로 insert하고 저장한다.  

앱이 종료되거나 백그 -> 포어그라운드 등으로 변환될 때 항상 BibleReadingTracker.checkIfCurrentEntryIsOutdated()를 호출해야 한다.


---

# 개념

쿼리에 와일드카드 채울 때 이렇게 선언해야함 (✅)(바인딩 로직이 디비 준비하는 함수 아래)
```
  let query = "SELECT * FROM \(tableName) WHERE year = ? AND month = ? AND day = ?"

  if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
    sqlite3_bind_int(statement, 1, Int32(year))
    sqlite3_bind_int(statement, 2, Int32(month))
    sqlite3_bind_int(statement, 3, Int32(day))
    return true
  }
```


이럼 안됨 (❌)

```
  let query = "SELECT * FROM \(tableName) WHERE year = ? AND month = ? AND day = ?"
  sqlite3_bind_int(statement, 1, Int32(year))
  sqlite3_bind_int(statement, 2, Int32(month))
  sqlite3_bind_int(statement, 3, Int32(day))
  if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
    return true
  }
```
