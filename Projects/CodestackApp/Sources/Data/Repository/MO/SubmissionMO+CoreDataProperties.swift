//
//  SubmissionMO+CoreDataProperties.swift
//  CodeStack
//
//  Created by 박형환 on 12/5/23.
//
//

import Foundation
import CoreData
import Global

extension SubmissionMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubmissionMO> {
        return NSFetchRequest<SubmissionMO>(entityName: "Submission")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: String?
    @NSManaged public var statusCode: String?
    @NSManaged public var codeContext: CodeContextMO?
    @NSManaged public var problemSubmissionState: ProblemSubmissionStateMO?
    @NSManaged public var submissionCalendar: SubmissionCalendarMO?
    @NSManaged public var language: LanguageMO?

}

extension SubmissionMO : Identifiable {
    func toDomain() -> SubmissionVO? {
        guard let id = self.id,
              let statusCode = self.statusCode,
              let codeContextVO = self.codeContext?.toDomain(),
              let languageVO = self.language?.toDomain(),
                let createdAt = self.createdAt
        else {
            return nil
        }
        
        return SubmissionVO(id: id,
                            sourceCode: codeContextVO.code,
                            problem: ProblemIdentityVO.init(id: codeContextVO.problemID,
                                                            title: codeContextVO.problemTitle),
                            member: MemberNameVO(username: ""),
                            language: languageVO,
                            cpuTime: 0,
                            memoryUsage: 0,
                            statusCode: statusCode,
                            createdAt: createdAt.toString())
              
    }
}

extension SubmissionVO {
    func toMO(in context: NSManagedObjectContext) -> SubmissionMO? {
        guard
            let submissionMO = SubmissionMO.insertNew(in: context),
            let languageMO = self.language.toMO(in: context)
        else {
            return nil
        }
        
        let codeContextVO = CodeContextVO(code: self.sourceCode,
                                      problemID: self.problem.id,
                                      problemTitle: self.problem.title)
        guard let codeContextMO = codeContextVO.toMO(in: context) else {
            return nil }
        
        submissionMO.createdAt = self.createdAt.toDateKST()
        submissionMO.id = self.id
        submissionMO.statusCode = self.statusCode
        submissionMO.codeContext = codeContextMO
        submissionMO.language = languageMO
        
        languageMO.submission = submissionMO
        codeContextMO.submission = submissionMO
        return submissionMO
    }
}
