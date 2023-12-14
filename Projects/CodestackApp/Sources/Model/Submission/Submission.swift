//
//  Submission.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
//

import Foundation
import CodestackAPI


//[FProblemIdentity]
//
//FMember
//
//FSubmission
//
//[FProblem],FPageInfo
//
//FProblem
//
//[FTag],FPageInfo
//
//[FLanguage]
//
//[FSubmission]
//
//[FSubmission],FPageInfo)


extension SubmissionFR {
    func toDomain() -> SubmissionVO {
        SubmissionVO(id: self.id,
                     sourceCode: self.sourceCode,
                     problem: self.problem.fragments.problemIdentityFR.toDomain(),
                     member: MemberNameVO(username: self.member.username),
                     language: self.language.fragments.languageFR.toDomain(),
                     cpuTime: self.cpuTime ?? -1,
                     memoryUsage: self.memoryUsage ?? -1,
                     statusCode: self.statusCode ?? "fail",
                     createdAt: self.createdAt)
    }
}

extension ProblemIdentityFR {
    func toDomain() -> ProblemIdentityVO {
        ProblemIdentityVO(id: self.id,
                          title: self.title)
    }
    
    func toSubVO() -> SubmissionVO {
        SubmissionVO(id: "",
                     sourceCode: "",
                     problem: self.toDomain(),
                     member: .init(username: ""),
                     language: .init(id: "", name: "", extension: ""),
                     cpuTime: 0,
                     memoryUsage: 0,
                     statusCode: "",
                     createdAt: "")
    }
    
}
extension LanguageFR {
    func toDomain() -> LanguageVO {
        LanguageVO(id: self.id,
                   name: self.name,
                   extension: self.extension)
    }
}

extension PageInfoFR {
    func toDomain() -> PageInfoVO {
        PageInfoVO(limit: self.limit,
                   offset: self.offset,
                   totalContent: self.totalContent,
                   totalPage: self.totalPage)
    }
}

extension ProblemFR {
    
    func toDomain() -> ProblemVO {
        ProblemVO(id: self.id,
                  title: self.title,
                  context: self.context,
                  languages: self.languages.map { $0.fragments.languageFR.toDomain() },
                  tags: self.tags.map { $0.fragments.tagFR.toDomain() },
                  accepted: self.accepted,
                  submission: self.submission,
                  maxCpuTime: self.maxCpuTime,
                  maxMemory: self.maxMemory)
    }
    
    func toIdentifyFR() -> ProblemIdentityFR {
        // TODO: 체크해야됌
        try! ProblemIdentityFR(data: ["id" : self.id, "title" : self.title])
    }
}

extension TagFR {
    func toDomain() -> TagVO {
        TagVO(id: String(self.id),
              name: self.name)
    }
}


struct Submission: Codable {
    var id: String?
    var sourceCode: String?
    var problem: Problem?
    var member: User?
    var language: Language?
    var cpuTime: Int?
    var memoryUsage: Int?
    var statusCode: String?
    var isTemp: Bool?
    var isFavorite: Bool?
    var createdAt: String?
}

//MARK: - Default initializer
extension Submission {
    init( _problem: Problem){
        id = nil
        sourceCode = nil
        problem = _problem
        member = nil
        language = nil
        cpuTime = nil
        memoryUsage = nil
        statusCode = nil
        isTemp = nil
        isFavorite = nil
        createdAt = nil
    }
    
    init(_problem: Problem,status code: String){
        self.init(_problem: _problem)
        self.statusCode = code
    }
    
    init(id: Int,
         sourceCode: String,
         problem: Problem,
         member: User,
         language: Language,
         cpuTime: Int, memoryUsage: Int,
         statusCode: String,
         isTemp: Bool,
         isFavorite: Bool,
         createdAt: String) {
        
        self.id = String(id)
        self.sourceCode = sourceCode
        self.problem = problem
        self.member = member
        self.language = language
        self.cpuTime = cpuTime
        self.memoryUsage = memoryUsage
        self.statusCode = statusCode
        self.isTemp = isTemp
        self.isFavorite = isFavorite
        self.createdAt = createdAt
    }
}

//MARK: GraphQL mapping initializer
extension Submission {
    /// GraphQL Mutation Submission Result
//    /// - Parameter submission: CreateSubmissionMutation Result
//    init(with submission: SubmissionMutation) {
//        self.id = submission.id
//        self.statusCode = submission.statusCode
//        self.problem = Problem(create: submission.problem)
//        self.member = User(with: submission.member)
//        self.language = Language(with: submission.language)
//        self.cpuTime = nil
//        self.sourceCode = submission.sourceCode
//        self.memoryUsage = nil
//        self.statusCode = submission.statusCode
//        self.createdAt = submission.createdAt
//    }
//    
//    init(submission: GetSubmissions.Content){
//        self.id = submission.id
//        self.statusCode = submission.statusCode
//        self.problem = Problem(id: submission.problem.id, title: submission.problem.title)
//        self.language = Language(id: submission.language.id, name: submission.language.name, _extension: "")
//        self.statusCode = submission.statusCode
//        self.createdAt = submission.createdAt
//    }
//    
    mutating func ifNetworkErorr() -> Self {
        if self.problem?.languages == nil  {
            self.problem?.languages = Language.sample
        }
        
        if self.problem!.languages.isEmpty {
            self.problem?.languages = Language.sample
        }
        
        return self
    }
}


extension Submission {
    
    struct SubmissionState {
        var submissions: [Submission]
    }
    
    struct Temp {
        var submission: [Submission]
    }
    
    struct Favorite {
        var problemID: ID
    }
}


//MARK: - make Dummy Data
#if DEBUG
extension Submission {
    
    static func dummy(type: SegType.Value? = nil) -> [Self]{

        let dummy = [Submission(_problem: Problem(title: "hello"),status: "AC"),
                     Submission(_problem: Problem(title: "my"),status: "WA"),
                     Submission(_problem: Problem(title: "name"),status: "RE"),
                     Submission(_problem: Problem(title: "is"),status: "PE"),
                     Submission(_problem: Problem(title: "hyeong"),status: "WA"),
                     Submission(_problem: Problem(title: "hwan"),status: "AC"),
                     Submission(_problem: Problem(title: "zzz"),status: "AC"),
                     Submission(_problem: Problem(title: "hahaha"),status: "TLE"),
                     Submission(_problem: Problem(title: "no~"),status: "MLE"),
                     Submission(_problem: Problem(title: "no~"),status: "favorite")]
        
        if let type {
            return dummy.filter{ submission in
                return submission.statusCode?.checkIsEqual(with: type) ?? false
            }
        }else{
            return dummy
        }
    }
}
#endif
