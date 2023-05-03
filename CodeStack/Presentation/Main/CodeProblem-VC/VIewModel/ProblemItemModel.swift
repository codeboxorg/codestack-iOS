//
//  ProblemModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/16.
//

import Foundation

struct ProblemListItemModel{
    var problemNumber: Int
    var problemTitle: String
    var submitCount: Int
    var correctAnswer: Int
    var correctRate: Double
    
    init(problemNumber: Int, problemTitle: String, submitCount: Int, correctAnswer: Int, correctRate: Double) {
        self.problemNumber = problemNumber
        self.problemTitle = problemTitle
        self.submitCount = submitCount
        self.correctAnswer = correctAnswer
        self.correctRate = correctRate
    }
    
    init(){
        self.problemNumber = 0
        self.problemTitle = ""
        self.submitCount = 0
        self.correctAnswer = 0
        self.correctRate = 0
    }
    
}

struct PMLanguage{
    var languages: [String]
}

