//
//  SubmissionMO+CoreDataProperties.swift
//  Data
//
//  Created by 박형환 on 12/16/23.
//  Copyright © 2023 hyeong. All rights reserved.
//
//

import Foundation
import CoreData
import Domain

extension SubmissionMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubmissionMO> {
        return NSFetchRequest<SubmissionMO>(entityName: "Submission")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: String?
    @NSManaged public var statusCode: String?
    @NSManaged public var codeContext: CodeContextMO?
    @NSManaged public var language: LanguageMO?
    @NSManaged public var problemSubmissionState: ProblemSubmissionStateMO?
    @NSManaged public var submissionCalendar: SubmissionCalendarMO?

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
    func updateMO(mo: SubmissionMO) -> SubmissionMO {
        mo.codeContext?.code = self.sourceCode
        mo.codeContext?.problemID = self.problem.id
        mo.codeContext?.problemTitle = self.problem.title
        mo.language?.languageID = self.language.id
        mo.language?.name = self.language.name
        mo.language?.extension = self.language.extension
        mo.statusCode = self.statusCode
        mo.createdAt = self.createdAt.isKSTORUTC()
        return mo
    }
    
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
        
        submissionMO.createdAt = self.createdAt.isKSTORUTC()
        submissionMO.id = self.id
        submissionMO.statusCode = self.statusCode
        submissionMO.codeContext = codeContextMO
        submissionMO.language = languageMO
        
        languageMO.submission = submissionMO
        codeContextMO.submission = submissionMO
        return submissionMO
    }
}

