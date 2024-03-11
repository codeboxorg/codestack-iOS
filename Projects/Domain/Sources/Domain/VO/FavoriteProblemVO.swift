//
//  FavoriteProblemVO.swift
//  CodestackApp
//
//  Created by 박형환 on 12/13/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation

public struct FavoriteProblemVO {
    public let problemID: String
    public let problmeTitle: String
    public let createdAt: Date
    
    public init(problemID: String, problmeTitle: String, createdAt: Date) {
        self.problemID = problemID
        self.problmeTitle = problmeTitle
        self.createdAt = createdAt
    }
}

public extension FavoriteProblemVO {
    
    func toSubmissionVO() -> SubmissionVO {
        
        // TODO: Favorite Model 변경 예정
        // Favorite Problem VO 에는 submission ID값이 없음 왜냐하면 제출을 안한 상태이기 때문에
        // 일단 UUID를 넣어주고, 추후에 생각? -> 지금은 HIstory VIew 에서만 Favorite를 보여준다고 하면
        // favorite에서 들어갔을때 -> 기존에 임시저장을 하고 있었다면 -> fetch 해와야함 DBREpository 에서
        // PRoblem의 Language List를 가져와야함 -> 지금은 Sample
        
        SubmissionVO(id: UUID().uuidString,
                     sourceCode: "",
                     problem: ProblemIdentityVO(id: problemID, title: problmeTitle),
                     member: MemberVO.sample.toNameVO,
                     language: .default,
                     statusCode: .favorite,
                     cpuTime: 0,
                     memoryUsage: 0,
                     createdAt: createdAt.toString())
    }
}
