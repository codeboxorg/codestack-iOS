//
//  Submission.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
//

import Foundation
import CodestackAPI
import Domain

extension MemberFR {
    func toDomain() -> MemberVO {
        MemberVO(email: self.email ?? "",
                 nickName: self.nickname,
                 username: self.username,
                 solvedProblems: self.solvedProblems.map { $0.fragments.problemIdentityFR.toDomain() },
                 profileImage: self.profileImage ?? "codeStack")
    }
}

extension SubmissionFR {
    func toDomain() -> SubmissionVO {
        SubmissionVO(id: self.id,
                     sourceCode: self.sourceCode,
                     problem: self.problem.fragments.problemIdentityFR.toDomain(),
                     member: MemberNameVO(username: self.member.username),
                     language: self.language.fragments.languageFR.toDomain(),
                     statusCode: SolveStatus(rawValue: self.statusCode ?? "none") ?? .none,
                     cpuTime: self.cpuTime ?? -1,
                     memoryUsage: self.memoryUsage ?? -1,
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
                     statusCode: .none,
                     cpuTime: 0,
                     memoryUsage: 0,
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
