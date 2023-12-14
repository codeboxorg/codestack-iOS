//
//  SubmissionVO.swift
//  CodestackApp
//
//  Created by 박형환 on 12/13/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation



public struct SubmissionInfoVO: Codable {
    public let submissionInfoList: [SubmissionVO]
    public let pageInfo: PageInfoVO
    
    public init(submissionInfoList: [SubmissionVO], pageInfo: PageInfoVO) {
        self.submissionInfoList = submissionInfoList
        self.pageInfo = pageInfo
    }
}

public struct SubmissionVO: Codable {
    var id: String
    var sourceCode: String
    var problem: ProblemIdentityVO
    var member: MemberNameVO
    var language: LanguageVO
    var cpuTime: Double
    var memoryUsage: Double
    var statusCode: String
    var createdAt: String
    
    public init(id: String, sourceCode: String, problem: ProblemIdentityVO, member: MemberNameVO, language: LanguageVO, cpuTime: Double, memoryUsage: Double, statusCode: String, createdAt: String) {
        self.id = id
        self.sourceCode = sourceCode
        self.problem = problem
        self.member = member
        self.language = language
        self.cpuTime = cpuTime
        self.memoryUsage = memoryUsage
        self.statusCode = statusCode
        self.createdAt = createdAt
    }
}

extension SubmissionVO {
    static var sample: Self {
        .init(id: "",
              sourceCode: "",
              problem: .init(id: "", title: ""),
              member: .init(username: ""),
              language: .init(id: "", name: "", extension: ""),
              cpuTime: -1,
              memoryUsage: -1,
              statusCode: "",
              createdAt: Date().toString())
    }
}
