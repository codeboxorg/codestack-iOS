//
//  Array+Extension.swift
//  CodestackApp
//
//  Created by 박형환 on 12/14/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation
import Global

public extension Array where Element == SubmissionVO {
    
    /// 같은 Problem ID를 찾는 함수,
    /// 임시저장을 배열에서 일치하는 제출을 찾아서 업데이트 할때 필요한 extension 함수
    /// - Parameter model: SendProblemModel
    /// - Returns: 일치하는 Submission
    func find(model: SubmissionVO) -> SubmissionVO? {
        self.first(where: { $0.problem.id == model.problem.id ? true : false })
    }
    
    func deleteEqual(problemID: ProblemID) -> Self {
        self.filter { $0.problem.id == problemID ? false : true }
    }
    
    func deleteEqualStatusCodes(receive: SubmissionVO) -> Self {
        self.filter { subVO in
            let con1 = subVO.problem.id == receive.problem.id
            let con2 = subVO.statusCode == receive.statusCode
            let con = con1 && con2
            return con ? false : true
        }
    }
    
    func sortByDate(_ latest: Bool = true) -> Self {
        self.sorted(by: { s1,s2 in
            let createdAt1 = s1.createdAt.isKSTORUTC()
            let createdAt2 = s2.createdAt.isKSTORUTC()
            return latest ? createdAt1 > createdAt2 : createdAt1 < createdAt2
        })
    }
}

public extension Array where Element == StoreVO {
    func sortByDate(_ latest: Bool = true) -> Self {
        self.sorted(by: { s1,s2 in
            let createdAt1 = s1.date.toYYMMDD() ?? Date()
            let createdAt2 = s2.date.toYYMMDD() ?? Date()
            return latest ? createdAt1 > createdAt2 : createdAt1 < createdAt2
        })
    }
}
