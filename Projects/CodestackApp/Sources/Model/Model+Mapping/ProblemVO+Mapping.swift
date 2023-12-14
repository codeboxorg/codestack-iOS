//
//  Problem.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
//

import Foundation
import CodestackAPI


//MARK: - To View Model
extension ProblemVO {
    func toProblemList(_ submission: SubmissionVO? = nil) -> ProblemListItemModel {
        return ProblemListItemModel(submissionID: submission?.id ?? UUID().uuidString,
                                    seletedLanguage: submission?.language ?? LanguageVO.default,
                                    sourceCode: submission?.sourceCode ?? "",
                                    problemNumber: self.id,
                                    problemTitle: self.title ,
                                    submitCount: Int(self.submission) ,
                                    correctAnswer: Int(self.accepted) ,
                                    correctRate: self.submission.toRate(second: self.accepted),
                                    contenxt: self.context,
                                    tags: self.tags,
                                    languages: self.languages)
    }
}

