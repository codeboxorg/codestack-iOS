//
//  Problem.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
//

import Foundation


struct _Problem: Codable{
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
}



struct _ProblemPagedResult: Codable{
    let content: [_Problem]
    let pageInfo: _PageInfo
}
