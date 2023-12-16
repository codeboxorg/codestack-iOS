//
//  ProblemSubmissionStateMO-extension.swift
//  CodeStack
//
//  Created by 박형환 on 11/28/23.
//

import CoreData
import Domain

extension ProblemSubmissionStateMO {
    
    // MARK: Probelm Submission StateMO 가 존재하면 fetch 후 리턴
    // 존재하지 않으면 생성 후 리턴
    static func fetchSubmissionStateMO(context: NSManagedObjectContext,
                                       newSubmission: SubmissionMO) throws -> ProblemSubmissionStateMO? {
        
        let stateMOs = try context.fetch(ProblemSubmissionStateMO.fetchRequest())
        var _problemSubmissionStateMO: ProblemSubmissionStateMO?
        
        if stateMOs.count == 0 {
            _problemSubmissionStateMO = ProblemSubmissionStateMO.insertNew(in: context)
            return _problemSubmissionStateMO
        }
        
        let newProblemID: String = newSubmission.codeContext?.problemID ?? ""
        let stateMO = stateMOs.first!
        
        guard let stateMOSubmissions = stateMO.submissions?.toArray(of: SubmissionMO.self) else { return nil }
        let ids = stateMOSubmissions.compactMap(\.codeContext?.problemID)
        let flag = ids.contains(newProblemID)
        
        if flag {
            guard let submissions = stateMO.submissions else { return nil }
            let values: [SubmissionMO] = submissions.compactMap { submission in
                guard
                    let _submissionMO = submission as? SubmissionMO,
                    let _problemID = _submissionMO.codeContext?.problemID
                else {
                    return nil
                }
                return newProblemID == _problemID ? newSubmission : _submissionMO
            }
            stateMO.submissions = NSSet(array: values)
        }
        return stateMO
    }
}

extension PR_SUB_ST_TYPE {
    func conditionRequest() -> NSFetchRequest<ProblemSubmissionStateMO> {
        switch self {
        case .all:
            return ProblemSubmissionStateMO.fetchRequest()
        case .isEqualID(let problemID):
            return ProblemSubmissionStateMO.fetchRequest()
        }
    }
}
