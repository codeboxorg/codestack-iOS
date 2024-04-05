//
//  FavoriteProblemMO-extension.swift
//  CodeStack
//
//  Created by 박형환 on 12/7/23.
//

import CoreData
import Domain

extension FAV_TYPE {
    func conditionRequest() -> NSFetchRequest<FavoritProblemMO> {
        switch self {
        case .all:
            return FavoritProblemMO.fetchRequest()
        case .isEqualID(let problemID):
            return FavoritProblemMO.isEqualID(probelmID: problemID)
        }
    }
}

extension FavoritProblemMO {
    static func isEqualID(probelmID: ProblemID) -> NSFetchRequest<FavoritProblemMO> {
        let request = newFetchRequest()
        let predicate1 = NSPredicate(format: "problemID == %@", "\(probelmID)")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [ predicate1 ])
        return request
    }
    
}


extension CodestackMO {
    static func isEqualID(_ id: String) -> NSFetchRequest<CodestackMO> {
        let request = newFetchRequest()
        let predicate1 = NSPredicate(format: "id == %@", "\(id)")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [ predicate1 ])
        request.fetchLimit = 1
        return request
    }
    
    static func isEqualLanguage(languageVO: LanguageVO) -> NSFetchRequest<CodestackMO> {
        let request = newFetchRequest()
        
        let predicate1 = NSPredicate(format: "language.languageID == %@", "\(languageVO.id)")
        let predicate2 = NSPredicate(format: "language.name == %@", "\(languageVO.name)")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [ predicate1, predicate2 ])
        return request
    }
    
}
