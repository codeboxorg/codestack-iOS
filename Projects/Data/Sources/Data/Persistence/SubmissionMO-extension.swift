//
//  SubmissionMO-extension.swift
//  CodeStack
//
//  Created by 박형환 on 11/28/23.
//

import CoreData
import Global
import Domain

extension SubmissionMO {
    
    static func recent(probelm id: ProblemID, not code: StatusCode) -> NSFetchRequest<SubmissionMO> {
        let request = newFetchRequest()
        let predicate1 = NSPredicate(format: "codeContext.problemID == %@", "\(String(describing: id))")
        let predicate2 = NSPredicate(format: "statusCode != %@", "\(String(describing: code))")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.fetchLimit = 1
        request.sortDescriptors = [ NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }
    
    static func isEqualID(id: SubmissionID, _ probelmID: ProblemID) -> NSFetchRequest<SubmissionMO> {
        let request = newFetchRequest()
        let predicate1 = NSPredicate(format: "id == %@", "\(String(describing: id))")
        let predicate2 = NSPredicate(format: "codeContext.problemID == %@", "\(String(describing: probelmID))")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        return request
    }
    
    static func isEqualStatusCode(_ statusCode: StatusCode) -> NSFetchRequest<SubmissionMO> {
        let request = newFetchRequest()
        let predicate1 = NSPredicate(format: "statusCode == %@", "\(statusCode)")
        request.predicate = predicate1
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }
    
    static func isEqualIDStatus(submissionID: SubmissionID, status: StatusCode) -> NSFetchRequest<SubmissionMO> {
        let request = newFetchRequest()
        let predicate1 = NSPredicate(format: "statusCode == %@", "\(status)")
        let predicate2 = NSPredicate(format: "id == %@", "\(String(describing: submissionID))")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        request.fetchLimit = 1
        return request
    }
    
    static func isNotTempSubmission(probelmID: ProblemID, status: StatusCode) -> NSFetchRequest<SubmissionMO> {
        let request = newFetchRequest()
        let predicate1 = NSPredicate(format: "statusCode != %@", "\(status)")
        let predicate2 = NSPredicate(format: "codeContext.problemID == %@", "\(String(describing: probelmID))")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        return request
    }
    
    static func isExistSubmission(problemID: ProblemID) -> NSFetchRequest<SubmissionMO> {
        let request = newFetchRequest()
        let predicate1 = NSPredicate(format: "codeContext.problemID == %@", "\(String(describing: problemID))")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1])
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        // request.fetchLimit = 1
        return request
    }
    
    static func isEqualStatus(languageName: LanguageName, problemID: ProblemID, statusCode: StatusCode) -> NSFetchRequest<SubmissionMO> {
        let request = newFetchRequest()
        let predicate1 = NSPredicate(format: "language.name == %@", "\(languageName)")
        let predicate2 = NSPredicate(format: "codeContext.problemID == %@", "\(problemID)")
        let predicate3 = NSPredicate(format: "statusCode == %@", "\(statusCode)")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,
                                                                                predicate2,
                                                                                predicate3])
        return request
    }
}

extension SUB_TYPE {
    func conditionRequest() -> NSFetchRequest<SubmissionMO> {
        switch self {
        case .isExist(let problemID):
            return SubmissionMO.isExistSubmission(problemID: problemID)
        
        case .is_Equal_ST_ID(let submissionID, let statusCode):
            return SubmissionMO.isEqualIDStatus(submissionID: submissionID, status: statusCode)
            
        case .is_NOT_ST_Equal_ID(let problemID, let state):
            return SubmissionMO.isNotTempSubmission(probelmID: problemID, status: state)
        
        case .isEqualStatusCode(let statusCode):
            return SubmissionMO.isEqualStatusCode(statusCode)
            
        case .update(let submissionID, let problemID):
            return SubmissionMO.isEqualID(id: submissionID, problemID)
            
        case .recent(let problemID, let statusCode):
            return SubmissionMO.recent(probelm: problemID, not: statusCode)
            
        case .default:
            let request = SubmissionMO.newFetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
            request.fetchLimit = 10
            return request
        
        case .delete(let languageName, let problemID, let statusCode):
            return SubmissionMO.isEqualStatus(languageName: languageName,
                                              problemID: problemID,
                                              statusCode: statusCode)
        }
    }
}
