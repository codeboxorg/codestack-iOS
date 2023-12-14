//
//  SubmissionVO-Extension.swift
//  CodestackApp
//
//  Created by 박형환 on 12/14/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation


extension SubmissionVO {
    /// 제출 같은 language와 source코드 여부
    /// - Parameter other: 다른 제출 모델
    /// - Returns: 같은 내용인지 flag
    func isEqualContent(other: Self) -> Bool {
        if self.sourceCode == other.sourceCode,
           self.language.id == other.language.id {
            return true
        } else {
            return false
        }
    }
}
