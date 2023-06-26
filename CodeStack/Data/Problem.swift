//
//  Problem.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
//

import Foundation


struct Problem: Codable{
    let id: Int
    let title: String
    let context: String
    let maxCpuTime: Int
    let maxMemory: Int
    let submission: Int
    let accepted: Int
    let tags: [Tag]
    let languages: [Language]
}



struct ProblemPagedResult: Codable{
    let content: [Problem]
    let pageInfo: PageInfo
}
