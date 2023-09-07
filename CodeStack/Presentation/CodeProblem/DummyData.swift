//
//  DummyData.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/17.
//

import Foundation

typealias DummyModel = (model: ProblemListItemModel, language: [Language], flag: Bool)

struct DummyData{
    
    func getDummyDataModel(name: String) -> DummyModel{
        let model = ProblemListItemModel(problemNumber: String(Int.random(in: 100...100000)),
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
        
        
        let languese = newLang.map{ name in Language(id: "1", name: name, _extension: "ㅋ")}
        
        return (model,languese, true)
    }
    
    func getAllModels(limit: Int = 15, index: Int = 0) -> [DummyModel]{
        let model = [getDummyDataModel(name: "hellow World \(index)"),
                     getDummyDataModel(name: "ABC \(index)"),
                     getDummyDataModel(name: "별찍기 \(index)"),
                     getDummyDataModel(name: "Three Sum \(index)"),
                     getDummyDataModel(name: "Dynamic programming \(index)"),
                     getDummyDataModel(name: "DFS \(index)"),
                     getDummyDataModel(name: "BFS \(index)"),
                     getDummyDataModel(name: "Cell merge \(index)"),
                     getDummyDataModel(name: "CompactMap \(index)"),
                     getDummyDataModel(name: "filter \(index)"),
                     getDummyDataModel(name: "hellow World \(index)"),
                     getDummyDataModel(name: "ABC \(index)"),
                     getDummyDataModel(name: "별찍기 \(index)"),
                     getDummyDataModel(name: "Three Sum \(index)"),
                     getDummyDataModel(name: "Dynamic programming \(index)"),
                     getDummyDataModel(name: "DFS \(index)"),
                     getDummyDataModel(name: "BFS \(index)"),
                     getDummyDataModel(name: "Cell merge \(index)"),
                     getDummyDataModel(name: "CompactMap \(index)"),
                     getDummyDataModel(name: "filter \(index)")][0...limit].shuffled()
        return model
    }
    
    func fetchModels(limit: Int = 15, currentPage: Int) -> [DummyModel]{
        return [getDummyDataModel(name: "안녕하세요 : \(currentPage)"),
                getDummyDataModel(name: "안녕하세요 : \(currentPage)"),
                getDummyDataModel(name: "안녕하세요 : \(currentPage)"),
                getDummyDataModel(name: "안녕하세요 : \(currentPage)"),
                getDummyDataModel(name: "안녕하세요 : \(currentPage)"),
                getDummyDataModel(name: "안녕하세요 : \(currentPage)"),
                getDummyDataModel(name: "안녕하세요 : \(currentPage)"),
                getDummyDataModel(name: "안녕하세요 : \(currentPage)"),
                getDummyDataModel(name: "안녕하세요 : \(currentPage)"),
                getDummyDataModel(name: "안녕하세요 : \(currentPage)"),
                getDummyDataModel(name: "안녕하세요 : \(currentPage)"),
                getDummyDataModel(name: "안녕하세요 : \(currentPage)"),
                getDummyDataModel(name: "안녕하세요 : \(currentPage)"),
                getDummyDataModel(name: "안녕하세요 : \(currentPage)"),
                getDummyDataModel(name: "안녕하세요 : \(currentPage)")]
    }
}
