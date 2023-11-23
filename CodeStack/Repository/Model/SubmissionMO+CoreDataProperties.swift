//
//  SubmissionMO+CoreDataProperties.swift
//  CodeStack
//
//  Created by 박형환 on 11/22/23.
//
//

import Foundation
import CoreData


extension SubmissionMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubmissionMO> {
        return NSFetchRequest<SubmissionMO>(entityName: "Submission")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: String?
    @NSManaged public var statusCode: String?
    @NSManaged public var codeContext: CodeContextMO?

}

extension SubmissionMO : Identifiable {

}
