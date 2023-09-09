//
//  SourceModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/16.
//

import Foundation



struct _SourceModel{
    let id: Int
    var cpuTime: String?
    var memoryUsage: String?
    var statusCode: String?
    var sourceCode: String?
    var problem: ProblemModel
    var language: Lanaguage
    var member: User
    
    enum CodingKeys: String, CodingKey {
        case id
        case cpuTime = "cpu_time"
        case memoryUsage = "memory_usage"
        case statusCode = "status_code"
        case sourceCode = "source_code"
        case problem
        case language
        case member
    }
}

struct ProblemModel{
    let problemID: Int
    var title: String
    
    enum CodingKeys: String,CodingKey{
        case problemID = "id"
        case title
    }
}

struct Lanaguage{
    let languageID: Int
    let name: String
    
    enum CodingKeys: String,CodingKey{
        case languageID = "id"
        case name
    }
}

