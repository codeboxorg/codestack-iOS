//
//  TempSubmissionVO.swift
//  CodestackApp
//
//  Created by 박형환 on 12/13/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation

public struct TempSubmissionVO {
    public let id: String
    public var codeContext: CodeContextVO
    public var createdAt: Date
}

extension TempSubmissionVO {
//    static func tempSubmission(submission: SubmissionVO) -> TempSubmission {
//        let codeContext = CodeContext(code: submission.sourceCode,
//                                      problemID: submission.problem?.id,
//                                      problemTitle: submission.problem?.title)
//        return TempSubmission(id: submission.id!,
//                              codeContext: codeContext,
//                              createdAt: submission.createdAt?.toDateKST())
//    }
}
