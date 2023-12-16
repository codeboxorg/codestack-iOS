//
//  SendProblemModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/04.
//

import Foundation
import Domain

struct SendProblemModel {
    let submissionID: SubmissionID
    let problemID: ProblemID
    let problemTitle: String
    let sourceCode: String
    let language: LanguageVO
    let userName: String = ""
    
    init(submissionID: SubmissionID, problemID: ProblemID, problemTitle: String = "", sourceCode: String, language: LanguageVO) {
        self.submissionID = submissionID
        self.problemID = problemID
        self.problemTitle = problemTitle
        self.sourceCode = sourceCode
        self.language = language
    }
    
    init(tuple: (LanguageVO, String, SourceCode, ProblemID, SubmissionID)){
        self.language = tuple.0
        self.problemTitle = tuple.1
        self.sourceCode = tuple.2
        self.problemID = tuple.3
        self.submissionID = tuple.4
    }
}

extension SendProblemModel {
    static var `default`: Self {
        .init(submissionID: "",
              problemID: "",
              problemTitle: "",
              sourceCode: "",
              language: LanguageVO.default)
    }
    
    func makeFavoirtProblem() -> FavoriteProblemVO {
        FavoriteProblemVO(problemID: self.problemID,
                          problmeTitle: self.problemTitle,
                          createdAt: Date())
    }
    
    func toProblemIdentity() -> ProblemIdentityVO {
        ProblemIdentityVO(id: self.problemID, title: self.problemTitle)
    }
    
    func toTempDomain() -> SubmissionVO {
        let submissionID = self.submissionID.isEmpty ? UUID().uuidString : self.submissionID
        return SubmissionVO.init(id: submissionID,
                                 sourceCode: self.sourceCode,
                                 problem: self.toProblemIdentity(),
                                 member: .init(username: self.userName),
                                 language: self.language,
                                 cpuTime: 0,
                                 memoryUsage: 0,
                                 statusCode: "temp",
                                 createdAt: Date().toString())
    }    
}
