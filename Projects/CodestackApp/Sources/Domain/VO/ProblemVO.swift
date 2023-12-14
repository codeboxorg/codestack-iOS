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
    
    public init(id: String, title: String, context: String, languages: [LanguageVO], tags: [TagVO], accepted: Double, submission: Double, maxCpuTime: String, maxMemory: Double) {
        self.id = id
        self.title = title
        self.context = context
        self.languages = languages
        self.tags = tags
        self.accepted = accepted
        self.submission = submission
        self.maxCpuTime = maxCpuTime
        self.maxMemory = maxMemory
    }
}

extension ProblemVO {
    func toSubVO() -> SubmissionVO {
//        SubmissionVO(id: <#T##String#>,
//                     sourceCode: <#T##String#>,
//                     problem: <#T##ProblemIdentityVO#>,
//                     member: <#T##MemberNameVO#>,
//                     language: <#T##LanguageVO#>,
//                     cpuTime: <#T##Double#>,
//                     memoryUsage: <#T##Double#>,
//                     statusCode: <#T##String#>,
//                     createdAt: <#T##String#>)
    }
}
