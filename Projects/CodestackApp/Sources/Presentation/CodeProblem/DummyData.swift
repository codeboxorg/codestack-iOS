//
//  DummyData.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/17.
//

import Foundation
import Domain


// TODO: DummyMOdel 확인후 모델명 변경 해야함
// typealias DummyModel = (model: ProblemListItemModel, language: [LanguageVO], flag: Bool)

struct AnimateProblemModel {
    var problemVO: ProblemVO
    var flag: Bool
    
    init(problemVO: ProblemVO = .sample,
         flag: Bool = false)
    {
        self.problemVO = problemVO
        self.flag = flag
    }
}

extension AnimateProblemModel {
    func getDummyDataModel(name: String, problemNumber: String) -> Self {
        let problem = ProblemVO(id: problemNumber,
                                title: name,
                                context: "",
                                languages: [],
                                tags: [],
                                accepted: 0,
                                submission: 0,
                                maxCpuTime: "5.0",
                                maxMemory: 100)
        return AnimateProblemModel(problemVO: problem, flag: false)
    }
    
    func getAllModels(limit: Int = 15, index: Int = 0) -> [AnimateProblemModel] {
        let numbers = (10000...100010).map { num in
            num + (10 * index)
        }
        
        let model = [getDummyDataModel(name: "hello World \(index)",problemNumber: String(numbers[0])),
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
