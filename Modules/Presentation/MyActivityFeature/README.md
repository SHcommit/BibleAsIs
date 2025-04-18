
## BibleReadingPlanHome

- 이 뷰 컨트롤러는 추후에 기능이 확장될 수 있음.

- 예를들어 챌린지에서 복음서, The Bible 90 Days Challenge 등 여러 챌린지들.
- 그러면 디비가 설계되야 함.

- 기능 확장을 고려 + 작은 기기도 고려해 스크롤뷰로 컴포넌트들 감쌈 


### DailyReadingPlanExpendingAnimator

- UIViewControllerAnimatedTransitioning 이 객체를 이제 UIViewControllerTransitioningDelegate 여기서 animationController(forPresented:) 이곳에서 present될 때 실행할 애니메이션으로! 넣기


#### 문제 1.
 - 스냅샷 안됨. 스냅샷이라 scale커지는 애니메이션 줄 때 까다로움. 그리고 나는 이미지도 확대 되어야함.
    scaleAsfectFit처럼
#### 문제 2.
- 그리고 frame 으로 애니메이션 해봤는데, 초기에 위치해야할 프레임이 적용이 안되고, startFrame.origin은 적용되는데 크기는 finalFrame.size 이게 적용되버림..

-> transform 쓰자!

#### 문제 3.
- 그리고 이게 transitionContext.view(forKey: .from) 이거로 fromVC를 가져올 수 없음..
     페이지컨트롤러를 사용중이기 때문에 좀 복잡함. 루트로부터 몇 번 체이닝 거쳐서 가져와야함.

---

## BaseNavigationVC에서 라지타이틀이 PageControl의 뷰컨에 있는 scrollable View에 적용 x
- 원했던 것은 패이지컨트롤에 등록된 뷰컨의 테이블뷰가 스크롤되면 MyActivityVC의 라지타이틀이 축소될 줄 알았으나
    네비게이션 컨트롤러의 루트에 등록된 scrollable뷰에 한정함.
  
  그래서 스크롤 offset활용하기로 함.

---

## 페이지뷰컨에서 주의할점.

> 우선 MyActivityVC 의 구조는 아래와 같다
```
NavigationController -> MyActivityVC 
                                - HeartHistoryVC
                                - HighlightVC
                                - ReadingPlanVC -> DetailVC
                                - NoteHomeVC -> DetailVC
```

이때 MyActivity는 페이지 컨트롤러 하에 4개의 뷰컨들의 화면 전환을 담당한다. 화면전환은 PageControl에서 담당하기 때문이다.
내부적으로 4개의 뷰컨에 대해 각각 새로운 네비게이션 컨트롤러를 주입하는것은 좋지 못하다. 내부 화면에서의 화면 이동이 이루어져서. (모달스타일바꿔도동일)

결국 present를 하거나, 네비게이션 컨트롤러로부터 직접 pushVC, pop를 해야한다.

나는 루트 네비게이션 을 상속받지 않고, 그냥 델리게이트 처리하기로 했다.
  아.. 참고로 페이지 뷰컨에선 각각의 뷰컨을 미리 생성하지 않고, 그냥 메뉴가 바뀌면 그때그떄 생성해서 주기로 했다. 
  cf. 뷰컨을 참조하면 해당 스크롤 위치도 그대로 저장이 된다(해당뷰컨에서)
  
  Anyway,, 좋지 않은 점은 NoteVC -> DetailVC로 네비게이션 컨트롤러 이동을 할 때 NoteVC에서 viewWillAppear가 호출된다.
  이는 스크롤 해서 새로운 페이지를 NoteHomeVC에서 specific Note VC로 이동하는데, 리프레시가 호출된다. 
  나는 편의를 위해서 note 데이터 fetch를 할 때 refresh용도인지? 아니면 기존 저장된 page정보를 활용해 다음 페이지 정보 받아온다.
  
  이때 리프래시가 호출되기 때문에, 기존에 저장된 특정 노트들이 다시 새로 받아져서 초기화 된다. 
  
  NoteHomeVC에서 15개 데이터씩 페이징 받는데, 2페이지(30개 데이터) 중 27번째 note 상세화면으로 들어가면, NoteHomeVC에서 리프레쉬가 호출되고(by view Will Appear) 그러면 노트 상세홤녀에서 제거하거나, 새로운 값으로 반영했을때 이전 데이터소스와 불일치가 생긴다.
  
  조심하자.
