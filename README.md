<img src="https://github.com/user-attachments/assets/54373e37-c9f9-40a3-9ff7-bc11fd559ae7" width="74" height="74" align="left"/>

# 성경대로

> 마음의 중심을 붙드는 성경 앱 - 성경대로

<a href="https://apps.apple.com/kr/app/%EC%84%B1%EA%B2%BD%EB%8C%80%EB%A1%9C/id6744650815">
    <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="앱스토어에서 다운로드" height="40"/>
</a>
<br/><br/>

```
통독표, 맥체인 읽기, 수면 타이머까지! 
광고 없이 성경을 묵상하며 하이라이트 및 메모를 통해 말씀을 기록하세요. 
하나님의 주권 아래 주어지는 데일리 랜덤 구절도 담았어요.
```

<details>
<summary>📖 성경대로 앱 소개 (눌러서 펼쳐주세요)</summary>

`성경대로는 성경 말씀을 기준 삼아 살아가고자 하는 이들을 위해 만들어졌습니다.`
우리의 삶의 모든 순간에도 말씀을 묵상함으로 삶의 기준이 성경이길 원합니다.

하루 한 장씩, 은혜로 하루를 시작하세요.
말씀을 따라 믿음으로 걸으며,
마음에 남는 구절은 하이라이트하고,
생각은 노트에 남겨보세요.

구약과 신약을 보기 쉽게 구성해
필요한 구절을 빠르게 찾고,
마음에 담은 구절은 하트로 저장할 수 있습니다.

하트 타임라인, 하나님의 주권에 기반한 데일리 말씀, 맥체인 성경 읽기,
그리고 읽은 장이 시각화되는 통독 표까지
말씀을 따라 걷는 여정을 돕는 기능들이 가득합니다.

밤에도 하나님을 바라보며
수면 타이머로 말씀과 함께 하루를 마무리할 수 있습니다.

광고 없이, 계정 없이, 모든 기능은 무료로
본질에 집중하고 복잡함은 최소화 했습니다.


> 여호와여 영광을 우리에게 돌리지 마옵소서
> 우리에게 돌리지 마옵소서 오직 주의 인자하심과
> 진실하심을 인하여 주의 이름에 돌리소서
>  `시편 115:1`

</details>

![1111](https://github.com/user-attachments/assets/a1bd8f6e-bc9f-4e2b-ab5c-57ebea7beb0e)
![2222](https://github.com/user-attachments/assets/a66b7e62-d2a4-4a0b-8e08-6e7e2345c76a)

## Role
- Design
- Wireframe, user flow 설계
- Search Engine, DB 구축 등 디비 설계
- iOS 앱 개발 및 출시

## Timeline & 마음가짐
![image](https://github.com/user-attachments/assets/42802898-4273-4bde-b8c2-878c17b1096b)

- 익숙하지 않은 기술이라도 적극적으로 공부하고 적용해 사용자가 느낄 수 있는 `자연스럽게` 동작하는 앱을 만들고 출시해보자!
- 더 좋은 화면 구성을 위해 다양한 성경 앱 뿐 아니라 다른 도서 앱들도 분석하며 좋은들을 참고해보자!
- user flow의 자연스러움을 위해 **애니메이션을 자유롭게 도입**해보자!
- 새로 떠오르는 아이디어는 **바로 메모**하고 UI로 만들고 구현해보자!

## Minimum iOS deployment version 
- iOS 13.0
- 여전히 활발히 사용되는 기기들을 폭 넓게 지원하기 위해 최소 iOS 배포 타겟을 13.0으로 설정했습니다.

## Dependencies
- Tuist (4.x)
- RxSwift, ReactorKit
- Swinject
- Sqlite3
- Then
- Firebase Crashlytics
- AcknowList
- Lottie

## Architecture

> Clean Architecture + Coordinator
> - Reactor flow
> - DI Container + Tuist

![image](https://github.com/user-attachments/assets/8d635a2f-d293-440f-95f5-0b8826986d40)

<details>
<summary>💉 DI Container 적용 Flow 소개 (눌러서 펼쳐주세요)</summary>
  
1. `Swinject`를 활용해 각 모듈은 자신만의 Assembly를 통해 특정 Container에 의존성을 등록합니다.
    이러한 모듈들은 보통 Interface 모듈을 제공하여 다른 모듈들이 인터페이스에 의존할 수 있도록 합니다.
2. Specific Feature Demo Target은 Sepcific Feature Module에서 의존하는 interface modules에 대한 구체타입, 모듈들을 알고 있고, 필요한 Assembly들을 조립하여 하나의 appDIContainer를 구성합니다.
3. 여러 Feature Demo app들은 전부 각각 선택적으로 특정 모듈들의 Assembly 또는 Feature module assembly를 조립하여 빌드하고, 실행 가능한 구조를 가집니다.
4. 모든 코드에 대한 테스트가 아닌, 정말 필요로되는 로직들, 실수할 가능성이 조금이라도 있는 로직들에 대해서 테스트를 진행했습니다. (e.g. Bible Module에서 CRUD 등등 - 실제 디비 접근이 아닌 인메모리 상에서 테스트)

</details>

<details>
<summary> 🖥 Custom Coordinator or RxFlow?! 채택 과정 소개 (눌러서 펼쳐주세요)</summary>
<pre>
RxFlow 도입을 위해 공부했지만 보다 단순한 구조로 Coordinator를 활용하기로 결정했습니다.
이전 프로젝트들에서는 Coordinator간의 계층 구조를 코디네이터 상위로부터 트리 형식으로 관리했지만, 
  실제로 화면을 보여주는 주체는 `UIViewController`이며, 
  `UINavigationController`가 참조하고 있기 때문에, 이를 활용하면 별도의 Coordinator 계층 구조를 유지하지 않아도 될 것 같다고 생각했습니다.
Navi -> AVC(RootVC) -> BVC -> CVC -> DVC. DVC에서 화면이 보여질 때 BVC로 가야한다면
  `popToViewController(_:animated:)`를 통해서도 충분히 가능하라라 판단했습니다.
</pre>

하나의 앱은 빌드 후 런타임시 필요로 되는 모듈들의 Assembly들을 Assembler가 조립(apply)하여 DI Graph를 가진 DI Container를 구성합니다.
- 각각의 Feature 모듈은 Gateway를 Entry point로 하며, Specific Feature 모듈의 Gateway 내부에서는 `Coordiantor`가 ViewController 및 필요로 되는 모든 의존성들을 Assembler를 통해 등록된 Assembly로부터 구체 타입 생성 과정이 담긴 DI graph를 resolve하여 인스턴스들을 생성하고 주입합니다.
- Coordinator는 뷰 컨트롤러 생성 및 화면 제어 역할을 갖습니다.
- 상위 코디네이터가 하위 코디네이터를 명시적으로 강하게 참조하지 않기에, Gateway의 특정 함수 scope에서 코디네이터를 선언하고 뷰 컨트롤러를 생성하여 화면이 보여진 후 Gateway의 특정 함수 scope가 스택 프레임에서 해제될 때 생성됬었던 코디네이터 인스턴스는 함께 release 됩니다.
- 화면 전환시에 여전히 해당 코디네이터가 필요로 함으로 VC에서 `코디네이터가 화면 전환을 위해 지원하는 flow들. Flow Dependencies 인터페이스`를 strong own함으로 네비게이션컨트롤러 -> 뷰컨트롤러 -> Coordinator 순의 참조 구조로 생명주기가 자연스럽게 유지되도록 구성했습니다.
</details>
  
## 화면 구성 : )

<img src="https://github.com/user-attachments/assets/e601808a-7e30-4f15-b7c0-fda600d6b1d1" width="200">|<img src="https://github.com/user-attachments/assets/823a3d93-a7e6-434f-8664-804f4ab10c1f" width="200">|<img src="https://github.com/user-attachments/assets/8d7a5b88-8469-4855-958f-02539dec0acd" width="200">|
|:-:|:-:|:-:|
|`홈 화면`|`홈 화면 - 오늘의 말씀 묵상`|`홈 화면 - lazy loading scroll`|

### 💪 도전 사항
1. 자연스러운 애니메이션.
2. 사용자가 스크롤 내려야만 동적으로 데이터를 받아와서 보여주는 기능 구현.

---

<img src="https://github.com/user-attachments/assets/c47f38d4-12c9-4d4e-bd77-1ea66ad90370" width="200">|<img src="https://github.com/user-attachments/assets/36d15f54-0581-4efa-b79b-a0db6b446c67" width="200">|<img src="https://github.com/user-attachments/assets/a0d21124-ddbf-44aa-b35d-6a70ca45ae4e" width="200">|
|:-:|:-:|:-:|
|`성경 목차 화면`|`성경 목차 expandable`|`Bible book 확장, 축소`|

### 💪 도전 사항
1. 편안하면서도 빠른 접근성.

---

<img src="https://github.com/user-attachments/assets/388f64ab-bed4-48d1-9a06-56fd7620c8e3" width="200">|<img src="https://github.com/user-attachments/assets/4d442038-b621-414a-9288-fab84ddfe24c" width="200">|<img src="https://github.com/user-attachments/assets/1ed78d82-a3f3-44d1-9e12-cd03599950de" width="200">|<img src="https://github.com/user-attachments/assets/6067dd31-b313-4b8e-93b0-7a7e8b93b5cf" width="200">|
|:-:|:-:|:-:|:-:|
|`검색 입력 동작 화면`|`검색 결과 화면`|`검색 결과 없음 화면`|`검색 홈 화면`|

### 💪 도전 사항
- UISearchController 활용
  - 성경 목차 화면 + 이 화면에서 처음 키보드 올라오는 속도가 느리므로 내부 동작을 미리 트리거 하여 입력 지연 최소화.

---

<img src="https://github.com/user-attachments/assets/aee9cce4-adb4-4890-b78d-a8bc6a09dedc" width="200">|<img src="https://github.com/user-attachments/assets/8c995de0-e292-48f1-b82b-e34d0b612309" width="200">|<img src="https://github.com/user-attachments/assets/aee9cce4-adb4-4890-b78d-a8bc6a09dedc" width="200">|<img src="https://github.com/user-attachments/assets/ccca6fe4-f228-4923-83ed-e42f9124d52c" width="200">|
|:-:|:-:|:-:|:-:|
|`성경 구절 마크들 활성화`|`제스처로 성경 읽기 화면 넘김`|`하트, 하이라이트들`|`노트 진입 화면`|

### 💪 도전 사항

<details>
<summary> 성경 읽기 화면 챕터 전환시 페이지 넘김 효과 도전기 (눌러서 펼쳐주세요)</summary>
  
- `성경 읽기 화면 챕터 넘김` 효과는 네이버 시리즈 앱 처럼 PageControl + isDoubled를 통해 정적인 데이터 환경에서 페이지 넘기는 효과를 성공적으로 구현했으나,
- 화면 전환시 실제로 비동기로 다음 화면의 Book의 모든 chapter에 대한 데이터를 그때 받아옴으로 화면 전환시 딜레이가 발생되어 이쁘지 않은 효과 발생됨...
- 로직이 아쉬워서 `내 활동` 탭의 각 화면 슬라이드 할 때 페이지 넘김 효과를 적용 했으나 하단에 탭바가 존재해 멋쩍은 페이지 넘김이 되서 아쉽게 적용하지 못했음 😭

</details>

- 최소 타겟이 13.0이므로 iOS 15.0 기준 UITextView 터치 시 메뉴바 활성화 분기 처리를 대응해야 했음
  - 초반 메뉴바 활성화 되기까지 동작이 UISearchController처럼 느리므로 미리 트리거 하여 지연 최소화 대응.
- text가 동적으로 커짐과 축소됨에 따라 scroll bouncing 현상이 있었음(<a href="https://dev-with-precious-dreams.tistory.com/299">해결 과정 블로그 포스트 작성</a>)
- 노트 화면에서 초기 진입 시점 사용자 터치에 따라 바로 텍스트 작성 할 수 있게 기능 추가.
- 초기 노트 작성 or 노트 수정 여부에 따라 네비게이션 메뉴 아이콘 및 저장 기능 대응.
- 작성 된 노트의 수정 여부는 `Git commit`처럼 SHA-1 해시 활용해 내용 변경 이력 감지하는 방식 사용.
- 노트 진입시 초기 키보드 올라오는 활성화가 기기별 느리게 동작될 수 있기에 사전에 키보드 관련 프리로드 함으로 대응.

---

<img src="https://github.com/user-attachments/assets/dcbc9210-855d-4813-9c32-929853aa3449" width="200">|<img src="https://github.com/user-attachments/assets/97ab0fd4-156c-45c8-b972-a20620237713" width="200">|<img src="https://github.com/user-attachments/assets/18030588-4c89-4e81-8560-35028b0914ca" width="200">|<img src="https://github.com/user-attachments/assets/db4fd9ee-4bdb-402f-8f18-60b295c003e6" width="200">|
|:-:|:-:|:-:|:-:|
|`내 활동 - 맥 체인 체크 및 미션 진입 화면`|`내 활동 - 맥 체인 화면`|`체크 리스트 동작 화면`|`체크 리스트 화면`|

### 💪 도전 사항
- 줄에 작은 Day 미션들이 매달려 있는 효과를 주고 싶었고 이동할 때 바람에 흔들리는 애니메이션 효과를 주고 싶었음.
  - (4개의 미션 성공시 Day 달력이 뒤에 검은 선을 기준으로 360도 돌아가며 작아지는 애니메이션을 구현했으나 UI상 별로여서 현재 기능 최종 적용)
- 체크리스트 화면 들어갈 때 편안함을 주고 싶었음.
  - 초기에는 단순히 통독표를 체크하는 기능만 있었는데, 성경의 구절은 3만 1천 구절이고, 66권 각각의 chapter도 많기에 대쉬 보드처럼 한 눈에 볼 수 있도록 66권을 그룹화하고 그래프로 시각화함.

---

<img src="https://github.com/user-attachments/assets/029f81f4-d539-467d-bf96-fd45763c5d93" width="200">|<img src="https://github.com/user-attachments/assets/2592e799-1a01-4469-9512-f93055bbc6fa" width="200">|<img src="https://github.com/user-attachments/assets/7a0d4860-4969-43c6-a52b-45dfe56bf703" width="200">|<img src="https://github.com/user-attachments/assets/a5446983-ead7-4c4d-91b9-dab3692c45fb" width="200">|
|:-:|:-:|:-:|:-:|
|`내 활동 - 하트 화면`|`내 활동 - 하이라이트 빈 화면`|`형광펜->하트->노트 터치 동작 화면`|`내 활동 - 노트 리스트 화면`|

### 💪 도전 사항

- 가장 큰 고민은, 앱 첫 실행 시 온보딩 화면을 제공하긴 했지만
  - 사용자가 이후 화면을 둘러보면서 **온보딩 내용을 쉽게 잊게 될 것 같다는 점**이었음.
  - 초기 구현은 단순히 비어있음을 알리는 일러스트를 보여주었지만,
  - 하이라이트/하트/노트 화면을 처음 방문한 사용자에게
  - **"어떻게 이 화면을 활용할 수 있는지"를 자연스럽게 알려주는 방법**이 필요하다고 느낌.
  - 이에 따라, `노트 화면 접속 시(3번째 영상)`에는  
    **"구절을 두 번 터치해보세요"** 라는 힌트를  
    **작은 애니메이션으로 부각시켜 시선을 유도**하도록 구현함.
    추가로 하단에 기대 효과를 시각적으로 보여주는 **이미지 배너도 함께 추가**해 사용자의 이해를 도움.

<img src="https://github.com/user-attachments/assets/06dfd090-7c13-4644-9502-4324e551f170" width="200">

- `내 활동` 탭의 상단 메뉴바는 초기에 위와 같은 형식으로 구현했었고, 스크롤 할 때 "나의 활동" 이 사라지도록 구현했었으나 좀 색 다른 디자인을 주고 싶었음.
  - 크롬이나 브라우저, 또는 책갈피 효과를 주고 싶었고 위 동영상 과 같이 같이 UI를 변경함.
  - 초기 구현했던 로직처럼 화면 위는 상단 메뉴 뷰 + 하단 Page Control로 구성된것은 동일했지만, 페이지별로 위에 책갈피(메뉴)를 붙여주면 네이버 시리즈 앱 처럼 사용자가 페이지를 넘기는 효과를 줄 때
  - 정말 보기 좋겠다는 생각이 들어 구현했으나 하단에 탭바가 여전히 고정되어 부자연스러워서 `.pageCurl` + IsDoubled 효과를 포기함.
---

## Bible, DesignSystem은 GitSubmodule로 private하게 관리


---

## Build & Setup Guide
### How to run BibleAsIs Project?
```
/// origin 등록 후 받아보자! + .gitsubmodules 활용
1. git pull --recurse-submodules origin develop

/// 설치
1. tuist install
2. make generateDEV or make generateRPD ( For release )
  - 환경 변수 세팅
3. Feature 모듈을 새로 구성할 경우 해당 New feature module에서 의존하는 interface 의 구체 Module의 Assembly를 등록해서 실행시점에 등록해야 원활하게 돌아갑니다.

/// clean
make clean
```

### Git Submodule Workflow!
#### Case: 단순 서브모듈 수정 후 커밋
```
1. Modules/Bible 등 private submodule 디렉터리 위치까지 이동
2. 이 서브모듈은 역시 git repo에 대한 .git이 있으므로 독립적인 branch를 갖게 됨. 여기서 git stage에서 새롭게 변경 사항 커밋
3. "../BibleAsIs/" 이 루트 디렉터리까지 다시 와서 서브모듈 업데이트 커밋
```

#### Case: git main module, submodules 같이 코드 수정한 경우
```
1. 반드시 서브 모듈들 부터 변경 사항 커밋 😅
2. 각각의 서브 모듈들 수정 사항 커밋 후 루트 레포로 돌아와서 서브 모듈의 commit pointer 커밋
```
