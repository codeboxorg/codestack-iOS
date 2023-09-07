# codestack-iOS
codestack를 제작하기 위한 ios 클라이언트입니다.


### Codestack Architecture
---
<img width="682" alt="Codestack 전체 Architecture" src="https://github.com/codeboxorg/codestack-iOS/assets/46890291/ed34c3ca-2c24-46e1-a343-5cc6b734cd01">

- App (Codestack) : Coordinator, ApolloGraphQL, Login, RxFlow, RxSwift, RxCocoa
- Flow : RxFlow를 활용하여 화면 전환 의존성을 ViewController에서 분리
- Presenstion : OnBoarding, Login, Home, ProblemList, Editor, History, MyPage ViewController
- Service : OAuth (git, apple), email 로그인, Keychain , GraphQL 쿼리 관련 네트워크 로직
- Repository : Rxswift를 활용하여 Apollo Query, mutation을 래핑
- CodestackAPI : Apollo CLI 로 생성된 쿼리 등 모델을 패키지로 분리
  /n



### Tech
---
- 언어 : Swift
- 아키텍처 : MVVM + Coordinator
- 비동기 처리 : RxSwift, RxCocoa
- 네트워크 처리 : Apollo GraphQL, URLSession
- 코디네이터 패턴 활용 : 각 뷰컨트롤러에 의존성 주입
- 커스텀 뷰 재활용
- 협업 : Discord, Slack


## Flow
작성중..
<img width="753" alt="Codestack Flow Architecture" src="https://github.com/codeboxorg/codestack-iOS/assets/46890291/e3cf87b5-f470-469f-8aab-1371389bf10b">

<br></br>
## Presentation
작성중..
<img width="888" alt="Codestack Presentation Architecture" src="https://github.com/codeboxorg/codestack-iOS/assets/46890291/74b61e4b-ad19-4ca4-9c54-79f7e82ed0a8">

<br></br>
## Service
작성중..
<img width="634" alt="Codestack Service Architecture" src="https://github.com/codeboxorg/codestack-iOS/assets/46890291/01eeff89-fe66-4b69-bc28-92edcdcb69df">

<br></br>
## Repository
작성중..
<img width="722" alt="Codestack Repository Architecture" src="https://github.com/codeboxorg/codestack-iOS/assets/46890291/542df1eb-0ea7-4ee2-b1f2-df6d45d6656d">

<br></br>
## 전체
작성중..
<img width="1060" alt="Codestack 전체 구조도" src="https://github.com/codeboxorg/codestack-iOS/assets/46890291/ed4f2403-a122-4321-8b53-7d285e7d7ea1">

