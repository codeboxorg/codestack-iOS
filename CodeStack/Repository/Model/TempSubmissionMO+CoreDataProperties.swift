//
//  TempSubmissionMO+CoreDataProperties.swift
//  CodeStack
//
//  Created by 박형환 on 11/22/23.
//
//

import Foundation
import CoreData


extension TempSubmissionMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TempSubmissionMO> {
        return NSFetchRequest<TempSubmissionMO>(entityName: "TempSubmission")
    }

    @NSManaged public var id: String
    @NSManaged public var createdAt: Date?
    @NSManaged public var codeContext: CodeContextMO?

}

extension TempSubmissionMO : Identifiable {

}
