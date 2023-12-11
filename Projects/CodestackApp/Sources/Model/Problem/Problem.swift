//
//  Problem.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
//

import Foundation
import CodestackAPI

struct Problem: Codable,Equatable{
    let id: String
    let title: String
    let context: String
    let maxCpuTime: Int
    let maxMemory: Int
    let submission: Double
    let accepted: Double
    let tags: [Tag]
    var languages: [Language]
    
    init(id: String = "", title: String, context: String = "", maxCpuTime: Int = 1, maxMemory: Int = 1, submission: Double = 1, accepted: Double = 1, tags: [Tag] = [], languages: [Language] = []) {
        self.id = id
        self.title = title
        self.context = context
        self.maxCpuTime = maxCpuTime
        self.maxMemory = maxMemory
        self.submission = submission
        self.accepted = accepted
        self.tags = tags
        self.languages = languages
    }
}


//MARK: - Submission Mutation Response Problem initializer
extension Problem {
    init(create problem: SubmissionProblem){
        self.id = problem.id
        self.title = problem.title
        self.context = problem.context
        self.maxCpuTime = Int(problem.maxCpuTime) ?? 0
        self.maxMemory = Int(problem.maxMemory)
        self.submission = 0
        self.accepted = 0
        self.tags = problem.tags.map{ Tag(with: $0)}
        self.languages = problem.languages.map{ Language(with: $0)}
    }
}


//MARK: - GetProblem Query Response initializer
extension Problem {
    init(problem: ProblemContent) {
        self.id = problem.id
        self.title = problem.title
        self.context = problem.context
        self.maxCpuTime = 0
        self.maxMemory = 0
        self.submission = problem.submission
        self.accepted = problem.accepted
        self.tags = problem.tags.map{ Tag(id: $0.id, name: $0.name) }
        self.languages = problem.languages.map{ Language(id: $0.id, name: $0.name, _extension: $0.extension)}
    }
}


//MARK: - To View Model
extension Problem{
    func toProblemList(_ submission: Submission? = nil) -> ProblemListItemModel{
        return ProblemListItemModel(submissionID: submission?.id,
                                    seletedLanguage: submission?.language,
                                    sourceCode: submission?.sourceCode,
                                    problemNumber: self.id,
                                    problemTitle: self.title ,
                                    submitCount: Int(self.submission) ,
                                    correctAnswer: Int(self.accepted) ,
                                    correctRate: self.submission.toRate(second: self.accepted),
                                    contenxt: self.context,
                                    tags: self.tags,
                                    languages: self.languages)
    }
}
