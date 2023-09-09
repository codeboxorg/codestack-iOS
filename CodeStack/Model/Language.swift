//
//  Language.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
//

import Foundation
import CodestackAPI

struct Language: Codable,Equatable{
    let id: String
    let name: String
    let _extension: String
}

extension Language{
    init(with lang: CreateSubmissionMutation.Data.CreateSubmission.Problem.Language){
        self.init(id: lang.id, name: lang.name, _extension: lang.extension)
    }
}

extension Language{
    init(with language: SubmissionMutation.Language){
        self.init(id: "", name: language.name, _extension: language.extension)
    }
}


