//
//  DummyData.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/17.
//

import Foundation

typealias DummyModel = (model: ProblemListItemModel, language: PMLanguage, flag: Bool)

struct DummyData{
    
    func getDummyDataModel(name: String) -> DummyModel{
        let model = ProblemListItemModel(problemNumber: 1,
                                         problemTitle: "\(name)",
                                         submitCount: Int.random(in: 10...134),
                                         correctAnswer: Int.random(in: 10...134),
                                         correctRate: Double.random(in: 0...100))
        let random = Int.random(in: 0...8)
        let lang =  ["C", "JAVA" , "C++", "Node.js", "Swift", "Kot", "Go", "Python", "javascript"]
        
        var newLang: [String] = []
        
        for i in 0..<random + 1 {
            newLang.append(lang[i])
        }
        let languese = PMLanguage(languages: newLang)
        
        return (model,languese, true)
    }
    
    func getAllModels() -> [DummyModel]{
        let model = [getDummyDataModel(name: "hellow World"),
                     getDummyDataModel(name: "ABC"),
                     getDummyDataModel(name: "별찍기"),
                     getDummyDataModel(name: "Three Sum"),
                     getDummyDataModel(name: "Dynamic programming"),
                     getDummyDataModel(name: "DFS"),
                     getDummyDataModel(name: "BFS"),
                     getDummyDataModel(name: "Cell merge"),
                     getDummyDataModel(name: "CompactMap"),
                     getDummyDataModel(name: "filter"),
                     getDummyDataModel(name: "hellow World"),
                     getDummyDataModel(name: "ABC"),
                     getDummyDataModel(name: "별찍기"),
                     getDummyDataModel(name: "Three Sum"),
                     getDummyDataModel(name: "Dynamic programming"),
                     getDummyDataModel(name: "DFS"),
                     getDummyDataModel(name: "BFS"),
                     getDummyDataModel(name: "Cell merge"),
                     getDummyDataModel(name: "CompactMap"),
                     getDummyDataModel(name: "filter"),
                     getDummyDataModel(name: "hellow World"),
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
