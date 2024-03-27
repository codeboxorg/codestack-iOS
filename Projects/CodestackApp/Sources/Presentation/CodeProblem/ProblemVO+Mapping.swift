//
//  Problem.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
//

import Foundation
import CodestackAPI
import Domain

//MARK: - To View Model
extension ProblemVO {
    func toProblemList(_ submission: SubmissionVO? = nil) -> ProblemListItemModel {
        var id: String = self.id
        var title: String = self.title
        var languages: [LanguageVO] = self.languages
        
        if let submission {
            if title != submission.problem.title {
                id = submission.problem.id
                title = submission.problem.title
                languages = LanguageVO.sample
            }
        }
        return ProblemListItemModel(submissionID: submission?.id ?? UUID().uuidString,
                                    seletedLanguage: submission?.language ?? LanguageVO.default,
                                    sourceCode: submission?.sourceCode ?? "",
                                    problemNumber: id,
                                    problemTitle: title ,
                                    submitCount: Int(self.submission) ,
                                    correctAnswer: Int(self.accepted) ,
                                    correctRate: self.submission.toRate(second: self.accepted),
                                    contenxt: self.context,
                                    tags: self.tags,
                                    languages: languages)
    }
}

