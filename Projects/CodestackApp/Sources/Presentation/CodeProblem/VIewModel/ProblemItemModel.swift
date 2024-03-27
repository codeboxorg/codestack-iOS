//
//  ProblemModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/16.
//

import Foundation
import Domain

struct ProblemListItemModel: Equatable {
    
    var submissionID: String?
    var seletedLanguage: LanguageVO?
    var sourceCode: String?
    var problemNumber: String
    var problemTitle: String
    var submitCount: Int
    var correctAnswer: Int
    var correctRate: Double
    var contenxt: String?
    var tags: [TagVO]
    var language: [LanguageVO]
    
    init(problemNumber: String,
         problemTitle: String,
         submitCount: Int,
         correctAnswer: Int,
         correctRate: Double,
         tags: [TagVO] = [],
         languages: [LanguageVO] = []) {
        
        self.submissionID = nil
        self.problemNumber = problemNumber
        self.problemTitle = problemTitle
        self.submitCount = submitCount
        self.correctAnswer = correctAnswer
        self.correctRate = correctRate
        self.tags = []
        self.language = languages
        self.contenxt = contextExample
    }
    
    init(submissionID: String? = nil,
         seletedLanguage: LanguageVO?,
         sourceCode: String?,
         problemNumber: String,
         problemTitle: String,
         submitCount: Int,
         correctAnswer: Int,
         correctRate: Double,
         contenxt: String,
         tags: [TagVO] = [],
         languages: [LanguageVO] = [])
    {
        self.submissionID = submissionID
        self.seletedLanguage = seletedLanguage
        self.sourceCode = sourceCode
        self.problemNumber = problemNumber
        self.problemTitle = problemTitle
        self.submitCount = submitCount
        self.correctAnswer = correctAnswer
        self.correctRate = correctRate
        self.contenxt = contenxt
        self.tags = tags
        self.language = languages
    }
    
    init(){
        self.problemNumber = ""
        self.problemTitle = ""
        self.submitCount = 0
        self.correctAnswer = 0
        self.correctRate = 0
        self.tags = []
        self.language = []
    }
}

extension ProblemListItemModel {
    static var mock: Self {
        .init(problemNumber: "0",
              problemTitle: "0",
              submitCount: 1,
              correctAnswer: 1,
              correctRate: 0)
    }
}

struct LanguageList{
    var languages: String
    var _extension: String
}

