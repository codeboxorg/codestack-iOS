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



public struct SubmissionVO: Codable, Equatable {
    public var id: String
    public var sourceCode: String
    public var problem: ProblemIdentityVO
    public var problemVO: ProblemVO
    public var member: MemberNameVO
    public var language: LanguageVO
    public var statusCode: SolveStatus
    public var cpuTime: Double
    public var memoryUsage: Double
    public var createdAt: String
    
    public init(id: String,
                sourceCode: String,
                problem: ProblemIdentityVO,
                problemVO: ProblemVO = ProblemVO.sample ,
                member: MemberNameVO,
                language: LanguageVO,
                statusCode: SolveStatus,
                cpuTime: Double,
                memoryUsage: Double,
                createdAt: String) {
        self.id = id
        self.sourceCode = sourceCode
        self.problem = problem
        self.problemVO = problemVO
        self.member = member
        self.language = language
        self.cpuTime = cpuTime
        self.memoryUsage = memoryUsage
        self.statusCode = statusCode
        self.createdAt = createdAt
    }
}

public extension SubmissionVO {
    static var sample: Self {
        .init(id: "sampleUID1234",
              sourceCode: "",
              problem: .init(id: "", title: "Sample"),
              member: .init(username: ""),
              language: .init(id: "", name: "Swift", extension: ".swift"),
              statusCode: .temp,
              cpuTime: -1,
              memoryUsage: -1,
              createdAt: "1999-12-25 10:10:10")
    }
    
    static var mock: Self {
        .init(id: "TestUID1234",
              sourceCode: "import Foudation",
              problem: .init(id: "테스트 제출 모델", title: "Hello World 0"),
              member: .init(username: "hwan"),
              language: .init(id: "-1", name: "Swift", extension: ".swift"),
              statusCode: .temp,
              cpuTime: -1,
              memoryUsage: -1,
              createdAt: "2030-12-15 10:10:10")
    }
    
    
    /// Sample은 CollectionView TableView를 위해서 뒤에 추가
    /// - Parameter count: mock 개수
    /// - Returns: Mock list
    static func getMocksForHome(_ count: Int = 3) -> [Self] {
        (0...count).map { _ in SubmissionVO.mock }
    }
    
    var isMock: Bool {
        self.id == "TestUID1234"
    }
    var isNotMock: Bool {
        self.id != "TestUID1234"
    }
    
    var isSample: Bool {
        self.id == "sampleUID1234"
    }
    
    func toSubmitMut() -> SubmitMutation {
        SubmitMutation(languageId: language.id,
                       problemId: problem.id,
                       sourceCode: sourceCode)
    }
}
