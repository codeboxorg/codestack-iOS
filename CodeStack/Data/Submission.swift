//
//  Submission.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
//

import Foundation


struct SubmissionPagedResult: Codable{
    let content: [Submission]
    let pageInfo: PageInfo
}
struct Submission: Codable{
    let id: Int
    let sourceCode: String
    let problem: Problem
    let member: Member
    let language: Language
    let cpuTime: Int
    let memoryUsage: Int
    let statusCode: String
    let createdAt: String
}
