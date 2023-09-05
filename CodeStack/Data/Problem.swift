//
//  Problem.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
//

import Foundation
import CodestackAPI

struct _Problem: Codable,Equatable{
    let id: Int
    let title: String
    let context: String
    let maxCpuTime: Int
    let maxMemory: Int
    let submission: Int
    let accepted: Int
    let tags: [Tag]
    let languages: [Language]
    
    init(id: Int = 1, title: String, context: String = "", maxCpuTime: Int = 1, maxMemory: Int = 1, submission: Int = 1, accepted: Int = 1, tags: [Tag] = [], languages: [Language] = []) {
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
    
    init(id: ID, title: String){
        self.init(id: Int(id) ?? -1 ,title: title)
    }
    
    
    
    init(create problem: CreateSubmissionMutation.Data.CreateSubmission.Problem){
        self.id = Int(problem.id) ?? 0
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


extension _Problem{
    func toProblemList() -> ProblemListItemModel{
        return ProblemListItemModel(problemNumber: self.id,
                                    problemTitle: self.title,
                                    submitCount: self.submission,
                                    correctAnswer: self.accepted,
                                    correctRate: Double(self.submission).toRate(second: self.accepted),
                                    contenxt: self.context,
                                    tags: self.tags,
                                    languages: self.languages)
    }
}




struct _ProblemPagedResult: Codable{
    let content: [_Problem]
    let pageInfo: _PageInfo
}
