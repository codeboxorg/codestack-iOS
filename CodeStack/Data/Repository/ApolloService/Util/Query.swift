//
//  GraphQuery.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/25.
//

import Foundation
import CodestackAPI


enum Mutation{
    
    static func problemSubmit(model: SendProblemModel) -> CreateSubmissionMutation {
        return CreateSubmissionMutation(languageId: model.language.id ,
                                        problemId: model.problemID,
                                        sourceCode: model.sourceCode)
    }
    
    static func problemSubmit(problemId: String, languageId: String, sourceCode: String) -> CreateSubmissionMutation {
        return CreateSubmissionMutation(languageId: languageId,problemId: problemId,sourceCode: sourceCode)
    }
    
    static func updateNickName(nickName: String) -> UpdateNickNameMutation {
        return UpdateNickNameMutation(nickname: nickName)
    }
}


enum Query{
    
    static func getSubmissionHistory(limit: Int = 30,offset: Int = 0) -> GetMeSubmissionHistoryQuery {
        GetMeSubmissionHistoryQuery(limit: .some(limit), offset: .some(offset))
    }
    
    static func getAllLanguage() -> GetAllLanguageQuery{
        GetAllLanguageQuery()
    }
    
    static func getAllSubmission(offset: Int, sort: String, order: String) -> GetSubmissionsQuery{
        GetSubmissionsQuery(offset: .some(offset), sort: .some(sort), order: .some(order))
    }
    
    static func getAllTag(offset: Int) -> GetAllTagQuery{
        GetAllTagQuery(offset: .some(offset))
    }
    
    static func getProblems(offset: Int, sort: String, order: String) -> GetProblemsQuery{
        GetProblemsQuery(offset: .some(offset), sort: .some(sort), order: .some(order))
    }
    
    static func getProblemByID(id: ID) -> GetProblemByIdQuery {
        GetProblemByIdQuery(id: id)
    }
    
    static func getMe() -> GetMeQuery{
        GetMeQuery()
    }
    
    static func getSolvedProblem(user name: String) -> GetSolvedProblemQuery{
        GetSolvedProblemQuery(username: name)
    }
    
    static func getMeSubmissions() -> GetMeSubmissionsQuery{
        GetMeSubmissionsQuery()
    }
    
    static func getSubmission(offest: Int = 0,
                              sort: String = "id",
                              order: String = "asc") -> GetSubmissionsQuery{
        GetSubmissionsQuery(offset: .some(offest), sort: "id", order: "asc")
    }
}



