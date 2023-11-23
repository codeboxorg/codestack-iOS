//
//  MySubmissionMO+CoreDataProperties.swift
//  CodeStack
//
//  Created by 박형환 on 11/22/23.
//
//

import Foundation
import CoreData


extension MySubmissionMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MySubmissionMO> {
        return NSFetchRequest<MySubmissionMO>(entityName: "MySubmission")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: String?

}

extension MySubmissionMO : Identifiable {

}
