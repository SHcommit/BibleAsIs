#  BibleNoteHomeFeature

### 사용될 수 있는 경우는 크게 2가지

1. pageController 내부에서 view로써 사용되는가?
2. ViewController 전체 화면을 차지하는가?

이 여부는 
```
BibleNoteGateway().makeViewController(forPageViewMode:)
```
이 매개변수에 true를 주입하면 1번, else 2번 경우가 된다.

--- 

### 주의 사항

- BibleNoteHomeReator에서는 BibleVerses, BibleNotes데이터가 들어오는데 이들은 한 쌍이다.
- 추가, 삭제를 할 때는 두개를 같이 동기화 해야한다.
- e.g. verses 에서 specific index가 제거되면 notes또한 마찬가지로 제거해야한다. 


---


### 마주한 에러
```
reactor.state
  .map { $0.isLoading }
  .distinctUntilChanged()
  .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
  .observe(on: MainScheduler.instance)
  .subscribe(onNext: { [weak self] loading in
    guard let self else { return }
    /// 초기에 rx(리엑터)도 컴바인처럼 initial setup을 함. ( 서로 pub, sub연결을 위해서 바인딩을 수행하는데 그때 호출된다.
    /// 그래서 이렇게 초기에 데이터가 없다면 return을 하도록 하자
    /// 안하면 UITableViewAlertForLayoutOutsideViewHierarchy 이런거 체크하라는 경고 나왐
    if reactor.numberOfItems == 0 { return }
    if loading { return }

    //        print(reactor.hasInitiallyFetched, reactor.currentState.reloadForNewPage)

    /// 초기에 진입될 때 isLoading이 아 이거 컬스택으로 암만봐도 isLoading을 reactor에서 방출하는 경우가 없는데.. false때매 initialState 때매 호출되는거네
    /// skip 1 써도 되는데 더 명확하게 하기위해서 noteView.tableFooterView == nil 이라는걸 추가했음 ㅎㅅㅎ
    /// 정확하게! isLoading 이어야만 tableFotoerView 가 true되니까.
    if noteView.tableFooterView == nil { return }
    noteView.tableFooterView = nil
    let startIndex = reactor.currentState.numberOfPrevItems
    let endIndex = reactor.currentState.items.count
    let indexPaths = (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }

    UIView.performWithoutAnimation {
      self.noteView.performBatchUpdates {
      self.noteView.insertRows(at: indexPaths, with: .none)
    }
  }
}).disposed(by: disposeBag)
```

reactor 특성상 구조체 바인딩이라 initialState일 때도 view reactor에선 반응을 해버림..
근데 희안하게도 이것보다도 데이터 fetch를 더 빨리하는 경우 가 있는지 모르겠지만, isLoading == false이고, 스크롤 자동으로 아래로 내려가지 않아서
showNextPage 페이징을 호출하지 않았음에도 불구하고!!!!!!!!! reactor.hasInitiallyFetched == true가 된 후에 isLoading == false 저 로직이
호출되는 경우가 발생함.. (당황) 가장 확실한것은 paging중일때 발생되는 인디케이터가 존재할 때만 !isLoading 인 경우에 하단 인디케이터를 제거하고
isnetRows를 호출해주어야 함 

반드시..!
