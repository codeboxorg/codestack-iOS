//
//  Tag.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
//

import Foundation
import CodestackAPI

struct Tag: Codable,Equatable{
    let id: Double
    let name: String
    
    init(id: Double,name: String){
        self.id = id
        self.name = name
    }
    
    init(with tag: CreateSubmissionMutation.Data.CreateSubmission.Problem.Tag){
        self.id = 0
        self.name = tag.name
    }
}
