# 성경대로

> 마음의 중심을 붙드는 성경 앱 - 성경대로

### <a href="https://apps.apple.com/kr/app/%EC%84%B1%EA%B2%BD%EB%8C%80%EB%A1%9C/id6744650815">앱스토어 다운받기</a>

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


## Architecture
![image](https://github.com/user-attachments/assets/42a5accc-830b-4e8a-b9d6-f37fe68aefd8)

1. `Swinject`를 활용해 각 모듈은 자신만의 Assembly를 통해 특정 Container에 의존성을 등록합니다. 이러한 모듈들은 보통 Interface 모듈을 제공하여 다른 모듈들이 인터페이스에 의존할 수 있도록 합니다.
2. Specific Feature Demo Target은 Sepcific Feature Module에서 의존하는 interface modules에 대한 구체타입, 모듈들을 알고 있고, 필요한 Assembly들을 조립하여 하나의 appDIContainer를 구성합니다.
3. 여러 Feature Demo app들은 전부 각각 선택적으로 특정 모듈들의 Assembly 또는 Feature module assembly를 조립하여 빌드하고, 실행 가능한 구조를 가집니다.

해야할거 : 아키텍처 , 깃허브 관리(private repoo), 모든 화면? 어떻게 프로젝트를 관리하는지
담당: 디비설계, 피그마, 아이폰 개발 ㄷ,ㅇ
