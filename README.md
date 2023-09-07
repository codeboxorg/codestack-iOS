# codestack-iOS
codestack를 제작하기 위한 ios 클라이언트입니다.


### Codestack Architecture
---
<img width="682" alt="Codestack 전체 Architecture" src="https://github.com/codeboxorg/codestack-iOS/assets/46890291/c2376b1d-d7b9-4928-a0a1-c8775052bee8">

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
<img width="753" alt="Codestack Flow Architecture" src="https://github.com/codeboxorg/codestack-iOS/assets/46890291/cdb7f55e-a090-4932-b5ad-c901832de4e7">

<br></br>
## Service
작성중..
<img width="634" alt="Codestack Service Architecture" src="https://github.com/codeboxorg/codestack-iOS/assets/46890291/755f6f13-bd0f-43ed-aab6-786a283077cb">

<br></br>
## Repository
작성중..
<img width="722" alt="Codestack Repository Architecture" src="https://github.com/codeboxorg/codestack-iOS/assets/46890291/c39d6cd8-539d-4b16-89f9-7006d653c87e">

<br></br>
## 전체
작성중..
<img width="1060" alt="Codestack 전체 구조도" src="https://github.com/codeboxorg/codestack-iOS/assets/46890291/bf44155f-6124-435d-ba08-089939a27555">

