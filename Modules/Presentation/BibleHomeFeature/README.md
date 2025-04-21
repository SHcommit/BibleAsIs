#  View 관련 메모!!


- 시스템은 셀 특성상 identifier과 같은 기본 이니셜 함수를 호출함. 그래서 ui reusable cell을 상속하고 그것을 등록하면 
- 그 자식 타입의 init이 호출되지 않고 부모의 생성자만 호출됨.

- 그래서 정말 조금만 다른 경우에 두개의 타입을 만들어서 등록해서 꺼내와 쓰는게 편함. 
- 그런데 이게 하나의 파일에 서로 다른 두 개의 타입을 지정하니까 문제는 old Testament가 셀 초반부에 나오고 new testament는 셀 후반부에 나오는데
- 후반부에 나오는 cell을 수정하고 실행은 old testament를 하게되는 경우가 발생함..
 
- 파일 개수 좀 줄이겠다고 이렇게 같지만 서로 다른 두 개의 타입을 하나의 파일에 선언하니까 이런 일이 있었따,,,, oBo 

--- 

```

reactor.state
  .compactMap { $0.updatableIndexPath }
  .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
  .observe(on: MainScheduler.instance)
  .subscribe(onNext: { [weak self] indexPath in
    guard let self else { return }
    print("터치 됬습니까?")
    if indexPath.section == 0 {
      let cell = tableView.cellForRow(at: indexPath) as? OldTestamentOfBookAccordionCell
      tableView.performBatchUpdates { cell?.configure(with: reactor.item(indexPath)) }
    } else {
      let cell = tableView.cellForRow(at: indexPath) as? NewTestamentOfBookAccordionCell
      tableView.performBatchUpdates{ cell?.configure(with: reactor.item(indexPath)) }
    }
  }
).disposed(by: disposeBag)
```

리엑터 보니까 스트림이 다시 뷰로 돌아올때 FP..? state를 아예 새로 반환하니까... 나와 관련없는, 이전 상태가 동일하게 유지되는건 제외를 
반드시 해야함. 이게 중요함. 안 그러면 나는 다른거 바꿨지만 state를 아예 새로 반환하니까 바인드 되어있는게 이전꺼와 동일한 값이지만 아래로 방출
시킬 수 있음..........


```
reactor.state
  .map { $0.updatableIndexPath }
  .distinctUntilChanged { $0 == nil && $1 == nil || $0 == $1 }
  .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
  .observe(on: MainScheduler.instance)
  .subscribe(onNext: { [weak self] indexPath in
    guard let indexPath else { return }
    guard let self else { return }
    print("터치 됬습니까?")
    if indexPath.section == 0 {
      let cell = tableView.cellForRow(at: indexPath) as? OldTestamentOfBookAccordionCell
      tableView.performBatchUpdates { cell?.configure(with: reactor.item(indexPath)) }
    } else {
      let cell = tableView.cellForRow(at: indexPath) as? NewTestamentOfBookAccordionCell
      tableView.performBatchUpdates{ cell?.configure(with: reactor.item(indexPath)) }
    }
  }
).disposed(by: disposeBag)
```
