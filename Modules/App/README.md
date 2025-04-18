#  BibleAsIs


- 기타 사항.
BaseNavigationController 초기화 할 때
뷰 컨트롤러 초기화 할땐 nilbName: nil, buldne: nil을 써야 다른 모듈에서 사용 가능함.


### 실행 방법.
- TUIST_BUILD_TARGET=DEV tuist generate
- TUIST_BUILD_TARGET=PRD tuist generate

- PRD(-> 스킴에서 build configuration 릴리즈로!)
위 경우는 파베까지 같이 실행되서 너무느려.. 


### Feed에서 reading challenge를 내 활동 탭에서도 동일하게 들어갈 수 있음.
이들은 공유되기 위해서 간단한건 같은 인스턴스 쓰게하는거고 swinject에선 in object scope container나 waek근데 container를 쓰면 Container동안
공유 가능. 근데 이게 네비게이션 바가 서로 달라서 충돌남.
다시 말해 뷰컨 A에 있는 UINavigationItem을 뷰컨 B에 복사해서 재사용해서 그럼 
```
*** Assertion failure in -[UINavigationBar layoutSubviews], UINavigationBar.m:3895
*** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Layout requested for visible navigation bar, <UINavigationBar: 0x1061160c0; frame = (0 56.3333; 402 44); opaque = NO; autoresize = W; layer = <CALayer: 0x600000280f40>> delegate=0x107841600 standardAppearance=0x600002934c40 scrollEdgeAppearance=0x600002934cb0 compactAppearance=0x600002934d20, when the top item belongs to a different navigation bar. topItem = <UINavigationItem: 0x1064364e0> style=navigator leftBarButtonItems=0x600000030660, navigation bar = <UINavigationBar: 0x10640b980; frame = (0 56.3333; 402 44); opaque = NO; autoresize = W; animations = { position=<CABasicAnimation: 0x60000032ca40>; }; layer = <CALayer: 0x60000023ad00>> delegate=0x10881f400 standardAppearance=0x60000291b790 scrollEdgeAppearance=0x60000291b800 compactAppearance=0x60000291b870, possibly from a client attempt to nest wrapped navigation controllers.'
*** First throw call stack:
    ...
```

viewWillAppear시점에 매번 데이터 받아올 수 있는데 끊겨보일거 같아서(물론 다른 화면은 한것도 있음 여러 화면에 의한 동기화 필요한 경우) 
탭 화면 이동하는거로 할까.. 고민이넴 (탭화면 노트 작성중이면 ..?!)


### BibleSearchFeature
바이블 탭에서 이제 서치바로 갈때 이게 간혹가다가 키보드 설정되고 취소 활성화 된 상태에서 다른 탭바 갔다가 다시 바이블 탭으로 오면 
문제가 좀 생김.. 난 SearchControlelr두 개 쓰는거니까 이게 아이패드에서 좀 더 그런 현상이 있더라고 최대한 지웠는데.
그래서 서치바 활성화 되면 탭바 깔끔하게 안 보여주는 것으로 할것임
