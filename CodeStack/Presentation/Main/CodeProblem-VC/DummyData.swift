//
//  DummyData.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/17.
//

import Foundation

typealias DummyModel = (model: ProblemListItemViewModel, language: PMLanguage)

struct DummyData{
    
    static func getDummyDataModel(name: String) -> DummyModel{
        let model = ProblemListItemViewModel(problemNumber: 1,
                                             problemTitle: "\(name)",
                                             submitCount: Int.random(in: 10...134),
                                             correctAnswer: Int.random(in: 10...134),
                                             correctRate: Double.random(in: 0...100))
        let languese = PMLanguage(languages: ["C", "JAVA" , "C++", "Node.js", "Swift", "Kotlin", "Go", "Python", "javascript"])
        
        return (model,languese)
    }
    
    static func getAllModels() -> [DummyModel]{
        let model = [getDummyDataModel(name: "hellow World"),
                     getDummyDataModel(name: "ABC"),
                     getDummyDataModel(name: "별찍기"),
                     getDummyDataModel(name: "Three Sum"),
                     getDummyDataModel(name: "Dynamic programming"),
                     getDummyDataModel(name: "DFS"),
                     getDummyDataModel(name: "BFS"),
                     getDummyDataModel(name: "Cell merge"),
                     getDummyDataModel(name: "CompactMap"),
                     getDummyDataModel(name: "filter")]
        return model
    }
}
