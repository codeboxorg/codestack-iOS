//
//  Submission.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
//

import Foundation

import CodestackAPI


struct SubmissionPagedResult: Codable{
    let content: [Submission]
    let pageInfo: _PageInfo
}

typealias SubmissionMutation = CreateSubmissionMutation.Data.CreateSubmission

struct Submission: Codable{
    var id: String?
    var sourceCode: String?
    var problem: _Problem?
    var member: _Member?
    var language: Language?
    var cpuTime: Int?
    var memoryUsage: Int?
    var statusCode: String?
    var createdAt: String?
    
    
    init( _problem: _Problem){
        id = nil
        sourceCode = nil
        problem = _problem
        member = nil
        language = nil
        cpuTime = nil
        memoryUsage = nil
        statusCode = nil
        createdAt = nil
    }
    
    init(_problem: _Problem,status code: String){
        self.init(_problem: _problem)
        self.statusCode = code
    }
    
    init(id: Int, sourceCode: String, problem: _Problem, member: _Member, language: Language, cpuTime: Int, memoryUsage: Int, statusCode: String, createdAt: String) {
        self.id = String(id)
        self.sourceCode = sourceCode
        self.problem = problem
        self.member = member
        self.language = language
        self.cpuTime = cpuTime
        self.memoryUsage = memoryUsage
        self.statusCode = statusCode
        self.createdAt = createdAt
    }
    
    
    /// GraphQL Mutation Submission Result
    /// - Parameter submission: CreateSubmissionMutation Result
    init(with submission: SubmissionMutation){
        self.id = submission.id
        self.statusCode = submission.statusCode
        self.problem = _Problem(create: submission.problem)
        self.member = _Member(with: submission.member)
        self.language = Language(with: submission.language)
        self.cpuTime = nil
        self.memoryUsage = nil
        self.statusCode = submission.statusCode
        self.createdAt = submission.createdAt
    }
    
    init(submission: GetSubmissions.Content){
        self.id = submission.id
        self.statusCode = submission.statusCode
        self.problem = _Problem(id: submission.problem.id, title: submission.problem.title)
        self.language = Language(id: submission.language.id, name: submission.language.name, _extension: "")
        self.statusCode = submission.statusCode
        self.createdAt = submission.createdAt
    }
    
}
extension Language{
    init(with language: SubmissionMutation.Language){
        self.init(id: "", name: language.name, _extension: language.extension)
    }
}

extension _Member{
    init(with member: SubmissionMutation.Member){
        self.nickname = member.nickname
        self.problemCalendar = []
        self.email = nil
        self.profileImage = nil
        self.username = nil
        self.year = nil
    }
}


extension Submission{
    
    static func dummy(type: SegType.Value? = nil) -> [Self]{

        let dummy = [Submission(_problem: _Problem(title: "hello"),status: "AC"),
                     Submission(_problem: _Problem(title: "my"),status: "WA"),
                     Submission(_problem: _Problem(title: "name"),status: "RE"),
                     Submission(_problem: _Problem(title: "is"),status: "PE"),
                     Submission(_problem: _Problem(title: "hyeong"),status: "WA"),
                     Submission(_problem: _Problem(title: "hwan"),status: "AC"),
                     Submission(_problem: _Problem(title: "zzz"),status: "AC"),
                     Submission(_problem: _Problem(title: "hahaha"),status: "TLE"),
                     Submission(_problem: _Problem(title: "no~"),status: "MLE"),
                     Submission(_problem: _Problem(title: "no~"),status: "favorite")]
        
        if let type {
            return dummy.filter{ submission in
                return submission.statusCode?.checkIsEqual(with: type) ?? false
            }
        }else{
            return dummy
        }
    }
}
