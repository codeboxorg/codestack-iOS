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
    let id: Int?
    let sourceCode: String?
    let problem: _Problem?
    let member: _Member?
    let language: Language?
    let cpuTime: Int?
    let memoryUsage: Int?
    let statusCode: String?
    let createdAt: String?

    
    init(){
        id = nil
        sourceCode = nil
        problem = nil
        member = nil
        language = nil
        cpuTime = nil
        memoryUsage = nil
        statusCode = nil
        createdAt = nil
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
    
    static func dummy() -> [Self]{
        return []
    }
    
}
//        [Submission(id: 12,
//                              sourceCode: "asdfasdf",
//                              problem: Problem(id: 3, title: "hellow world!", context: "설명", maxCpuTime: 10000, maxMemory: 10000, submission: 3, accepted: 2,
//                                               tags: [Tag(id: "12", name: "df")],
//                                               languages: [Language(id: 1, name: "C++", _extension: "cpp"),Language(id: 1, name: "java", _extension: "java")]),
//                              member: Member(username: "park", nickname: "hwan", email: "gudghks56", profileImage: "star", problemCalendar: [], year: "2023"),
//                              language: Language(id: 1, name: "C++", _extension: "cpp"),
//                              cpuTime: 2324,
//                              memoryUsage: 1123234,
//                              statusCode: "201",
//                              createdAt: Date().description),
//                   Submission(id: 12,
//                                         sourceCode: "asdfasdf",
//                                         problem: Problem(id: 3, title: "DFS!", context: "설명", maxCpuTime: 10000, maxMemory: 10000, submission: 3, accepted: 2,
//                                                          tags: [Tag(id: "12", name: "df")],
//                                                          languages: [Language(id: 1, name: "C++", _extension: "cpp"),Language(id: 1, name: "java", _extension: "java")]),
//                                         member: Member(username: "park", nickname: "hwan", email: "gudghks56", profileImage: "star", problemCalendar: [], year: "2023"),
//                                         language: Language(id: 1, name: "C++", _extension: "cpp"),
//                                         cpuTime: 2324,
//                                         memoryUsage: 1123234,
//                                         statusCode: "201",
//                                         createdAt: Date().description),
//                   Submission(id: 12,
//                                         sourceCode: "asdfasdf",
//                                         problem: Problem(id: 3, title: "미로 탐색 하기!", context: "설명", maxCpuTime: 10000, maxMemory: 10000, submission: 3, accepted: 2,
//                                                          tags: [Tag(id: "12", name: "df")],
//                                                          languages: [Language(id: 1, name: "C++", _extension: "cpp"),Language(id: 1, name: "java", _extension: "java")]),
//                                         member: Member(username: "park", nickname: "hwan", email: "gudghks56", profileImage: "star", problemCalendar: [], year: "2023"),
//                                         language: Language(id: 1, name: "C++", _extension: "cpp"),
//                                         cpuTime: 2324,
//                                         memoryUsage: 1123234,
//                                         statusCode: "201",
//                                         createdAt: Date().description),
//                   Submission(id: 12,
//                                         sourceCode: "asdfasdf",
//                                         problem: Problem(id: 3, title: "해보자 함!", context: "설명", maxCpuTime: 10000, maxMemory: 10000, submission: 3, accepted: 2,
//                                                          tags: [Tag(id: "12", name: "df")],
//                                                          languages: [Language(id: 1, name: "C++", _extension: "cpp"),Language(id: 1, name: "java", _extension: "java")]),
//                                         member: Member(username: "park", nickname: "hwan", email: "gudghks56", profileImage: "star", problemCalendar: [], year: "2023"),
//                                         language: Language(id: 1, name: "C++", _extension: "cpp"),
//                                         cpuTime: 2324,
//                                         memoryUsage: 1123234,
//                                         statusCode: "201",
//                                         createdAt: Date().description),
//                   Submission(id: 12,
//                                         sourceCode: "asdfasdf",
//                                         problem: Problem(id: 3, title: "달려라 허니!", context: "설명", maxCpuTime: 10000, maxMemory: 10000, submission: 3, accepted: 2,
//                                                          tags: [Tag(id: "12", name: "df")],
//                                                          languages: [Language(id: 1, name: "C++", _extension: "cpp"),Language(id: 1, name: "java", _extension: "java")]),
//                                         member: Member(username: "park", nickname: "hwan", email: "gudghks56", profileImage: "star", problemCalendar: [], year: "2023"),
//                                         language: Language(id: 1, name: "C++", _extension: "cpp"),
//                                         cpuTime: 2324,
//                                         memoryUsage: 1123234,
//                                         statusCode: "201",
//                                         createdAt: Date().description),
//                   Submission(id: 12,
//                                         sourceCode: "asdfasdf",
//                                         problem: Problem(id: 3, title: "소방대원 구출작전!", context: "설명", maxCpuTime: 10000, maxMemory: 10000, submission: 3, accepted: 2,
//                                                          tags: [Tag(id: "12", name: "df")],
//                                                          languages: [Language(id: 1, name: "C++", _extension: "cpp"),Language(id: 1, name: "java", _extension: "java")]),
//                                         member: Member(username: "park", nickname: "hwan", email: "gudghks56", profileImage: "star", problemCalendar: [], year: "2023"),
//                                         language: Language(id: 1, name: "C++", _extension: "cpp"),
//                                         cpuTime: 2324,
//                                         memoryUsage: 1123234,
//                                         statusCode: "201",
//                                         createdAt: Date().description),
//                   Submission(id: 12,
//                                         sourceCode: "asdfasdf",
//                                         problem: Problem(id: 3, title: "카카오 배달의 민족 !", context: "설명", maxCpuTime: 10000, maxMemory: 10000, submission: 3, accepted: 2,
//                                                          tags: [Tag(id: "12", name: "df")],
//                                                          languages: [Language(id: 1, name: "C++", _extension: "cpp"),Language(id: 1, name: "java", _extension: "java")]),
//                                         member: Member(username: "park", nickname: "hwan", email: "gudghks56", profileImage: "star", problemCalendar: [], year: "2023"),
//                                         language: Language(id: 1, name: "C++", _extension: "cpp"),
//                                         cpuTime: 2324,
//                                         memoryUsage: 1123234,
//                                         statusCode: "201",
//                                         createdAt: Date().description),
//                   Submission(id: 12,
//                                         sourceCode: "asdfasdf",
//                                         problem: Problem(id: 3, title: "이진 트리 구현!", context: "설명", maxCpuTime: 10000, maxMemory: 10000, submission: 3, accepted: 2,
//                                                          tags: [Tag(id: "12", name: "df")],
//                                                          languages: [Language(id: 1, name: "C++", _extension: "cpp"),Language(id: 1, name: "java", _extension: "java")]),
//                                         member: Member(username: "park", nickname: "hwan", email: "gudghks56", profileImage: "star", problemCalendar: [], year: "2023"),
//                                         language: Language(id: 1, name: "C++", _extension: "cpp"),
//                                         cpuTime: 2324,
//                                         memoryUsage: 1123234,
//                                         statusCode: "201",
//                                         createdAt: Date().description)]
//    }\

