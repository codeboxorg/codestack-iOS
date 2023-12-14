//
//  CodeContextMO+CoreDataProperties.swift
//  CodeStack
//
//  Created by 박형환 on 12/5/23.
//
//

import Foundation
import CoreData


extension CodeContextMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CodeContextMO> {
        return NSFetchRequest<CodeContextMO>(entityName: "CodeContext")
    }

    @NSManaged public var code: String?
    @NSManaged public var problemID: String?
    @NSManaged public var problemTitle: String?
    @NSManaged public var submission: SubmissionMO?

}

extension CodeContextMO : Identifiable {
    func toDomain() -> CodeContextVO? {
        guard
        let code = self.code,
        let problemID = self.problemID,
        let problemTitle = self.problemTitle
        else {
            return nil
        }
        return CodeContextVO(code: code,
                             problemID: problemID,
                             problemTitle: problemTitle)
    }
}

extension CodeContextVO {
    func toMO(in context: NSManagedObjectContext) -> CodeContextMO? {
        let codeContextMO = CodeContextMO.insertNew(in: context)
        codeContextMO?.code = self.code
        codeContextMO?.problemID = self.problemID
        codeContextMO?.problemTitle = self.problemTitle
        return codeContextMO
    }
}
