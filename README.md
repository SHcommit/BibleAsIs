# 성경대로

> 마음의 중심을 붙드는 성경 앱 - 성경대로

### <a href="https://apps.apple.com/kr/app/%EC%84%B1%EA%B2%BD%EB%8C%80%EB%A1%9C/id6744650815">앱스토어 다운받기 ( 완전무료!!!!!! ) </a>

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


## Minimum iOS deployment version 
- iOS 13.0
- 여전히 활발히 사용되는 기기들을 폭 넓게 지원하기 위해 최소 iOS 배포 타겟을 13.0으로 설정했습니다.

## Third parties
- RxSwift
- ReactorKit
- Swinject
- Then
- Firebase Crashlytics
- AcknowList
- Lottie

## Architecture
![image](https://github.com/user-attachments/assets/8d635a2f-d293-440f-95f5-0b8826986d40)

#### DI Container 활용
1. `Swinject`를 활용해 각 모듈은 자신만의 Assembly를 통해 특정 Container에 의존성을 등록합니다. 이러한 모듈들은 보통 Interface 모듈을 제공하여 다른 모듈들이 인터페이스에 의존할 수 있도록 합니다.
3. Specific Feature Demo Target은 Sepcific Feature Module에서 의존하는 interface modules에 대한 구체타입, 모듈들을 알고 있고, 필요한 Assembly들을 조립하여 하나의 appDIContainer를 구성합니다.
4. 여러 Feature Demo app들은 전부 각각 선택적으로 특정 모듈들의 Assembly 또는 Feature module assembly를 조립하여 빌드하고, 실행 가능한 구조를 가집니다.
5. 모든 코드에 대한 테스트가 아닌, 정말 필요로되는 로직들, 실수할 가능성이 조금이라도 있는 모듈들에 대해서 테스트를 진행했습니다. (e.g. Bible Module에서 CRUD 등등 - 실제 디비 접근이 아닌 인메모리 상에서 테스트)

#### Coordinator or RxFlow ?!
> RxFlow 도입을 위해 공부하였고 적용할까 생각했지만 보다 단순한 구조를 위해, Coordinator는 `뷰 컨트롤러의 생명주기` 및 `네비게이션 컨트롤러를 통한 화면 전환 제어` 역할에만 집중하도록 최소화 했습니다.
> 이전 프로젝트들에서는 Coordinator간의 계층 구조를 상위 코디네이터가 관리했지만, 실제로 화면을 보여주는 주체는 `UIViewController`이며, 이는 `UINavigationController`가 강하게 참조하고 있기 때문에,
> 별도의 Coordinator 계층 구조를 유지하지 않아도 충분하다고 판단하게 되었습니다.
> Navi -> AVC(RootVC) -> BVC -> CVC -> DVC -> EVC. EVC에서 화면이 보여질 때 BVC로 가야한다면 `popToViewController(_:animated:)`를 통해서도 충분히 가능하라라 생각했습니다.

- 하나의 앱은 빌드 후 런타임시 필요로 되는 모듈들의 Assembly들을 Assembler가 조립(apply)하여 DI Graph를 가진 DI Container를 구성합니다.
- 각각의 Feature 모듈은 Gateway를 Entry point로 하며, Specific Feature 모듈의 Gateway 내부에서는 `Coordiantor`가 ViewController 및 필요로 되는 모든 의존성들을 Assembler를 통해 등록된 Assembly로부터 구체 타입 생성 과정이 담긴 DI graph를 resolve하여 인스턴스들을 생성하고 주입합니다.
- Coordinator는 뷰 컨트롤러 생성 및 화면 제어 역할을 갖습니다.
- 상위 코디네이터가 하위 코디네이터를 명시적으로 강하게 참조하지 않기에, Gateway의 특정 함수 scope에서 코디네이터를 선언하고 뷰 컨트롤러를 생성하여 화면이 보여진 후 Gateway의 특정 함수 scope가 스택 프레임에서 해제될 때 생성됬었던 코디네이터 인스턴스는 함께 release 됩니다.
  - 화면 전환시에 여전히 해당 코디네이터가 필요로 함으로 VC에서 `코디네이터가 화면 전환을 위해 지원하는 flow들. Flow Dependencies 인터페이스`를 strong own함으로 네비게이션컨트롤러 -> 뷰컨트롤러 -> Coordinator 순의 참조 구조로 생명주기가 자연스럽게 유지되도록 구성했습니다.


## Project Execute
```
/// 설치
1. tuist install
2. make generateDEV or make generateRPD ( For Release )
  - 환경 변수 세팅
3. Feature 모듈을 새로 구성할 경우 해당 New feature module에서 의존하는 interface 의 구체 Module의 Assembly를 등록해서 실행시점에 등록해야 원활하게 돌아갑니다.

/// clean
make clean
```

해야할거 :  깃허브 관리(private repoo), 모든 화면? 어떻게 프로젝트를 관리하는지
담당: 디비설계, 피그마, 아이폰 개발 ㄷ,ㅇ
