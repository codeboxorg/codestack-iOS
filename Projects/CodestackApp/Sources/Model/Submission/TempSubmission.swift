//
//  TempSubmission.swift
//  CodeStack
//
//  Created by 박형환 on 11/22/23.
//

import Foundation


struct TempSubmission {
    let id: String
    var codeContext: CodeContext?
    var createdAt: Date?
}

extension TempSubmission {
    static func tempSubmission(submission: Submission) -> TempSubmission {
        let codeContext = CodeContext(code: submission.sourceCode,
                                      problemID: submission.problem?.id,
                                      problemTitle: submission.problem?.title)
        return TempSubmission(id: submission.id!,
                              codeContext: codeContext,
                              createdAt: submission.createdAt?.toDateKST())
    }
}
