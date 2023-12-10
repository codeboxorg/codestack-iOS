//
//  SendProblemModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/04.
//

import Foundation


struct SendProblemModel {
    let submissionID: ID
    let problemID: ID
    let problemTitle: String
    let sourceCode: String
    let language: Language
    
    init(submissionID: ID, problemID: ID, problemTitle: String = "", sourceCode: String, language: Language) {
        self.submissionID = submissionID
        self.problemID = problemID
        self.problemTitle = problemTitle
        self.sourceCode = sourceCode
        self.language = language
    }
    
    init(tuple: (Language, String, SourceCode, ProblemID, SubmissionID)){
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
              language: Language.default)
    }
    
    func makeFavoirtProblem() -> FavoriteProblem {
        FavoriteProblem(problemID: self.problemID,
                        problmeTitle: self.problemID,
                        createdAt: Date())
    }
    
    func makeTempSubmission() -> Submission {
        let submissionID = self.submissionID.isEmpty ? UUID().uuidString : self.submissionID
        return Submission(id: submissionID,
                          sourceCode: self.sourceCode,
                          problem: .init(id: self.problemID, title: self.problemTitle),
                          member: .init(),
                          language: self.language,
                          cpuTime: 0,
                          memoryUsage: 0,
                          statusCode: "temp",
                          createdAt: Date().toString())
    }
}
