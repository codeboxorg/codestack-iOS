//
//  Submission.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
//

import Foundation


struct SubmissionPagedResult: Codable{
    let content: [Submission]
    let pageInfo: _PageInfo
}

struct Submission: Codable{
    var id: Int?
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


extension Submission{
    
    static func convertSolveStatus(_ code: String) -> SolveStatus {
        switch code{
        case "fail":
            return .fail
        case "success":
            return .solve
        case "temp":
            return .temp
        case "favorite":
            return .favorite
        default:
            return .none
        }
    }
    
    static func dummy(type: SolveStatus? = nil) -> [Self]{
        
        let dummy = [Submission(_problem: _Problem(title: "hello"),status: "fail"),
                     Submission(_problem: _Problem(title: "my"),status: "success"),
                     Submission(_problem: _Problem(title: "name"),status: "temp"),
                     Submission(_problem: _Problem(title: "is"),status: "success"),
                     Submission(_problem: _Problem(title: "hyeong"),status: "success"),
                     Submission(_problem: _Problem(title: "hwan"),status: "temp"),
                     Submission(_problem: _Problem(title: "zzz"),status: "fail"),
                     Submission(_problem: _Problem(title: "hahaha"),status: "success"),
                     Submission(_problem: _Problem(title: "no~"),status: "fail"),
                     Submission(_problem: _Problem(title: "no~"),status: "favorite")]
        if let type {
            return dummy.filter{ Submission.convertSolveStatus($0.statusCode ?? "") == type }
        }else{
            return dummy
        }
    }
}
