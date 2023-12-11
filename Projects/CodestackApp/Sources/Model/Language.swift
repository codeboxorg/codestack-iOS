//
//  Language.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
//

import Foundation
import CodestackAPI

struct Language: Codable,Equatable {
    let id: String
    let name: String
    let _extension: String
}

extension Language {
    init(with lang: CreateSubmissionMutation.Data.CreateSubmission.Problem.Language){
        self.init(id: lang.id, name: lang.name, _extension: lang.extension)
    }
    
    static var `default`: Self {
        Language(id: "1",
                 name: "C",
                 _extension: ".c")
    }
    
    static var sample: [Self] {
        let lang =  ["C", "C++", "Node", "GO", "Python3"]
        let `extension` = [".c",".cpp", ".js", ".go", ".py"]
        
        let languages = zip(lang,`extension`).enumerated().map { (value) in
            let (offset, (name, ex)) = value
            return Language(id: "\(offset + 1)", name: name, _extension: "\(ex)")
        }
        return languages
    }
}

extension Language{
    init(with language: SubmissionMutation.Language){
        self.init(id: language.id, name: language.name, _extension: language.extension)
    }
}


