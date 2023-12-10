//
//  SubmissionMO-extension.swift
//  CodeStack
//
//  Created by 박형환 on 11/28/23.
//

import CoreData

extension SubmissionMO {
    
    typealias ProblemID = String
    typealias StatusCode = String
    typealias SubmissionID = String
    typealias LanguageName = String
    enum RequestType {
        case isExist(ProblemID)
        case isNotTemp(ProblemID, String)
        case isEqualStatusCode(String)
        case update(SubmissionID, ProblemID)
        case recent(ProblemID)
        case `default`
        case delete(LanguageName, ProblemID, StatusCode)
        
        func conditionRequest() -> NSFetchRequest<SubmissionMO> {
            switch self {
            case .isExist(let problemID):
                return SubmissionMO.isExistSubmission(problemID: problemID)
            
            case .isNotTemp(let problemID, let state):
                return SubmissionMO.isNotTempSubmission(probelmID: problemID, status: state)
            
            case .isEqualStatusCode(let statusCode):
                return SubmissionMO.isEqualStatusCode(statusCode)
                
            case .update(let submissionID, let problemID):
                return SubmissionMO.isEqualID(id: submissionID, problemID)
                
            case .recent(let problemID):
                return SubmissionMO.recent(probelm: problemID)
                
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
    
    static func recent(probelm id: ID) -> NSFetchRequest<SubmissionMO> {
        let request = newFetchRequest()
        let predicate1 = NSPredicate(format: "codeContext.problemID == %@", "\(id)")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1])
        request.fetchLimit = 1
        request.sortDescriptors = [ NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }
    
    static func isEqualID(id: ID, _ probelmID: ID) -> NSFetchRequest<SubmissionMO> {
        let request = newFetchRequest()
        let predicate1 = NSPredicate(format: "id == %@", "\(id)")
        let predicate2 = NSPredicate(format: "codeContext.problemID == %@", "\(probelmID)")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        return request
    }
    
    static func isEqualStatusCode(_ statusCode: String) -> NSFetchRequest<SubmissionMO> {
        let request = newFetchRequest()
        let predicate1 = NSPredicate(format: "statusCode == %@", "\(statusCode)")
        request.predicate = predicate1
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }
    
    static func isNotTempSubmission(probelmID: ID, status: String) -> NSFetchRequest<SubmissionMO> {
        let request = newFetchRequest()
        let predicate1 = NSPredicate(format: "statusCode != %@", "\(status)")
        let predicate2 = NSPredicate(format: "codeContext.problemID == %@", "\(probelmID)")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        return request
    }
    
    static func isExistSubmission(problemID: ID) -> NSFetchRequest<SubmissionMO> {
        let request = newFetchRequest()
        let predicate1 = NSPredicate(format: "codeContext.problemID == %@", "\(problemID)")
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
    
    func update(submission: Submission) -> Self {
        self.codeContext?.code = submission.sourceCode
        self.codeContext?.problemID = submission.problem?.id
        self.codeContext?.problemTitle = submission.problem?.title
        self.language?.languageID = submission.language?.id
        self.language?.name = submission.language?.name
        self.language?.extension = submission.language?._extension
        self.statusCode = submission.statusCode
        self.createdAt = submission.createdAt?.toDateKST()
        return self
    }
}
