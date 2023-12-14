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
    static func recent(probelm id: ProblemID) -> NSFetchRequest<SubmissionMO> {
        let request = newFetchRequest()
        let predicate1 = NSPredicate(format: "codeContext.problemID == %@", "\(String(describing: id))")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1])
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
