//
//  ProblemVO.swift
//  CodestackApp
//
//  Created by 박형환 on 12/13/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation



public struct ProblemInfoVO: Codable {
    public let probleminfoList: [ProblemVO]
    public let pageInfo: PageInfoVO
    
    public init(probleminfoList: [ProblemVO], pageInfo: PageInfoVO) {
        self.probleminfoList = probleminfoList
        self.pageInfo = pageInfo
    }
}

public struct ProblemVO: Codable {
    public let id: String
    public let title: String
    public let context: String
    public let languages: [LanguageVO]
    public let tags: [TagVO]
    public let accepted: Double
    public let submission: Double
    public let maxCpuTime: String
    public let maxMemory: Double
    public let probleminput: [String]
    public let expectOutput: [String]
    
    public init(id: String,
                title: String,
                context: String,
                languages: [LanguageVO],
                tags: [TagVO],
                accepted: Double,
                submission: Double,
                maxCpuTime: String,
                maxMemory: Double,
                probleminput: [String] = [],
                expectOutput: [String] = []) {
        self.id = id
        self.title = title
        self.context = context
        self.languages = languages
        self.tags = tags
        self.accepted = accepted
        self.submission = submission
        self.maxCpuTime = maxCpuTime
        self.maxMemory = maxMemory
        self.probleminput = probleminput
        self.expectOutput = expectOutput
    }
}

extension ProblemVO: Equatable {
    
    public static var sample: Self {
        .init(id: "", title: "'", context: "'", languages: [], tags: [], accepted: 0, submission: 0, maxCpuTime: "", maxMemory: 0)
    }
    
    public var isNotMock: Bool { self != ProblemVO.sample }

    
    public static var uploadList: [Self] = [
        ProblemVO.init(id: "1",
                       title: "연속된부분수열의합",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: ["부분수열", "DP"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0),
        ProblemVO.init(id: "2",
                       title: "원형부분수열",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: ["구현"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0),
        ProblemVO.init(id: "3",
                       title: "시험장나누기",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: ["이분탐색", "트리"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0),
        ProblemVO.init(id: "4",
                       title: "경주로 건설",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: ["백트랙킹", "DFS" , "DP"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0),
        ProblemVO.init(id: "5",
                       title: "아방가르드타일링",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: ["DP", "구현"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0),
        ProblemVO.init(id: "6",
                       title: "대충만든자판",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: ["Set", "구현"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0),
        ProblemVO.init(id: "7",
                       title: "길찾기게임",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: ["트리"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0),
        ProblemVO.init(id: "8",
                       title: "블록이동하기",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: ["BFS"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0),
        ProblemVO.init(id: "9",
                       title: "카드짝맞추기",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: ["BFS", "DFS", "구현"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0),
        ProblemVO.init(id: "10",
                       title: "틱택톡",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: ["구현"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0),
        ProblemVO.init(id: "11",
                       title: "마법의 엘리베이터",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: [ "구현"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0),
        ProblemVO.init(id: "12",
                       title: "코딩테스트 공부",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: ["DP", "구현"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0),
        ProblemVO.init(id: "13",
                       title: "멀리뛰기",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: ["DP", "구현"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0),
        ProblemVO.init(id: "14",
                       title: "던전피로도",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: ["완전탐색"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0),
        ProblemVO.init(id: "15",
                       title: "파괴되지않는건물",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: ["DP", "구현"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0),
        ProblemVO.init(id: "16",
                       title: "표편집",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: ["리스트", "구현"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0),
        ProblemVO.init(id: "17",
                       title: "땅따먹기",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: ["DP", "구현"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0),
        ProblemVO.init(id: "18",
                       title: "둘만의 암호",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: ["String"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0),
        ProblemVO.init(id: "19",
                       title: "양과늑대",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: ["DFS", "트리"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0),
        ProblemVO.init(id: "20",
                       title: "삼총사",
                       context: contextExample,
                       languages: LanguageVO.sample,
                       tags: ["경우의수"].map { TagVO(id: "", name: $0) },
                       accepted: 0,
                       submission: 0,
                       maxCpuTime: "0",
                       maxMemory: 0)
    ]
}

public var contextExample  =
   """
      <body><h1>땅따먹기</h1>
         <h3>문제 설명</h3>
         <p>땅따먹기 게임을 하려고 합니다. 땅따먹기 게임의 땅(land)은 총 N행 4열로 이루어져 있고, 모든 칸에는 점수가 쓰여 있습니다. 1행부터 땅을 밟으며 한 행씩 내려올 때, 각 행의 4칸 중 한 칸만 밟으면서 내려와야 합니다. 단, 땅따먹기 게임에는 한 행씩 내려올 때, 같은 열을 연속해서 밟을 수 없는 특수 규칙이 있습니다.
      예를 들면,</br>
      | 1 | 2 | 3 | 5 | </br>
      | 5 | 6 | 7 | 8 | </br>
      | 4 | 3 | 2 | 1 | </br>
      로 땅이 주어졌다면, 1행에서 네번째 칸 (5)를 밟았으면, 2행의 네번째 칸 (8)은 밟을 수 없습니다. </br>
      마지막 행까지 모두 내려왔을 때, 얻을 수 있는 점수의 최대값을 return하는 solution 함수를 완성해 주세요. </br> 위 예의 경우, 1행의 네번째 칸 (5), 2행의 세번째 칸 (7), 3행의 첫번째 칸 (4) 땅을 밟아 16점이 최고점이 되므로 16을 return 하면 됩니다. </p>

      <h3>제한 사항</h3>

      <p><li> 행의 개수 N : 100,000 이하의 자연수</li>
      <li> 열의 개수는 4개이고, 땅(land)은 2차원 배열로 주어집니다. </li>
      <li> 점수 : 100 이하의 자연수 </li>
      <section class="sample-body">
      <div class="sample-item">
      <div>
      <div class="sample-item-header">
      <div>예제입력 1</div>
      <button class="copy-button" data-clipboard-target="#sample-input-1">
      복사
      </button>
      </div>
      <div>
      <pre class="sample-data" id="sample-input-1"> [[1,2,3,5],[5,6,7,8],[4,3,2,1]]</pre>
      </div>
           </div>
               <div>
                   <div class="sample-item-header">
                   <div>예제출력 1</div>
                   <button class="copy-button" data-clipboard-target="#sample-output-1">
                       복사
                   </button>
                   </div>
                   <div>
                   <pre class="sample-data" id="sample-output-1">16</pre>
                   </div>
               </div>
               </div>
           </section></body></p>

      """
