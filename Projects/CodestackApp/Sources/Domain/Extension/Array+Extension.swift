//
//  Array+Extension.swift
//  CodestackApp
//
//  Created by 박형환 on 12/14/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation

extension Array where Element == SubmissionVO {
    
    /// 같은 Problem ID를 찾는 함수,
    /// 임시저장을 배열에서 일치하는 제출을 찾아서 업데이트 할때 필요한 extension 함수
    /// - Parameter model: SendProblemModel
    /// - Returns: 일치하는 Submission
    func find(model: SubmissionVO) -> SubmissionVO? {
        return self.filter { value in
            if value.problem.id == model.problem.id {
                return true
            }
            return false
        }.first
    }
}
