//
//  ConvertUtil.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/26.
//

import Foundation
import CodestackAPI

enum ConvertUtil{
    
    static func converting(submission: CreateSubmissionMutation.Data.CreateSubmission) -> Submission{
        let sub = submission
        
        let id = sub.id
        let status = sub.statusCode
        
        return Submission(id: id,
                          sourceCode: "",
                          problem: .init(title: "test"),
                          member: .init(),
                          language: .init(id: "", name: "", _extension: ""),
                          cpuTime: 0,
                          memoryUsage: 0,
                          statusCode: status!,
                          createdAt: "")
    }
    
    static func converting(problems: GetProblemsQuery.Data.GetProblems) -> [Problem]{
        let datas = problems.content.map {
            $0.map { data in
                
                let tag = data.tags.map{ tag in
                    Tag(id: tag.id, name: tag.name)
                }
                
                let languages = data.languages.map{ lan in
                    Language(id: lan.id, name: lan.name, _extension: lan.extension)
                }
               
                
                let problem = Problem(id: data.id, title: data.title, context: data.context, maxCpuTime: 0, maxMemory: 0,
                                       submission: data.submission, accepted: data.accepted, tags: tag, languages: languages)
                return problem
            }
        }
        return datas ?? []
    }
    
    static func converting(tag: GetAllTagQuery.Data.GetAllTag) -> [Tag]{
        tag.content.map {
            $0.map { data in
                print("tag: \(data.id)")
                print("tag: \(data.name)")
            }
        }
        return []
    }
    
    static func converting(data: [GetAllLanguageQuery.Data.GetAllLanguage]) -> [Language] {
        return data.map { lan in
            return Language(id: lan.id, name: lan.name, _extension: lan.extension)
        }
    }
    
    static func converting(all submission: GetSubmissionsQuery.Data.GetSubmissions) -> [Submission] { 
        submission.content.map{ content in
            return content.map{value in
            }
        }
        return []
    }
    
}
