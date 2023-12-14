//
//  DummyData.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/17.
//

import Foundation

typealias DummyModel = (model: ProblemListItemModel, language: [LanguageVO], flag: Bool)

struct DummyData{
    
    func getDummyDataModel(name: String, problemNumber: String) -> DummyModel{
        let model = ProblemListItemModel(problemNumber: problemNumber,
                                         problemTitle: "\(name)",
                                         submitCount: Int.random(in: 10...134),
                                         correctAnswer: Int.random(in: 10...134),
                                         correctRate: Double.random(in: 0...100))
        return (model, LanguageVO.sample, true)
    }
    
    func getAllModels(limit: Int = 15, index: Int = 0) -> [DummyModel]{
        let numbers = (10000...100010).map { num in
            num + (10 * index)
        }
        
        let model = [getDummyDataModel(name: "hellow World \(index)",problemNumber: String(numbers[0])),
                     getDummyDataModel(name: "ABC \(index)", problemNumber: String(numbers[1])),
                     getDummyDataModel(name: "별찍기 \(index)", problemNumber: String(numbers[2])),
                     getDummyDataModel(name: "Three Sum \(index)", problemNumber: String(numbers[3])),
                     getDummyDataModel(name: "Dynamic programming \(index)",problemNumber: String(numbers[4])),
                     getDummyDataModel(name: "DFS \(index)", problemNumber: String(numbers[5])),
                     getDummyDataModel(name: "BFS \(index)", problemNumber: String(numbers[6])),
                     getDummyDataModel(name: "Cell merge \(index)", problemNumber: String(numbers[7])),
                     getDummyDataModel(name: "CompactMap \(index)", problemNumber: String(numbers[8])),
                     getDummyDataModel(name: "filter \(index)", problemNumber:String(numbers[9]))
                     ]
        return model
    }
}
