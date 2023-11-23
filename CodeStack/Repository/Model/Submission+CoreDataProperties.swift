//
//  Submission+CoreDataProperties.swift
//  
//
//  Created by 박형환 on 11/22/23.
//
//

import Foundation
import CoreData


extension Submission {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Submission> {
        return NSFetchRequest<Submission>(entityName: "Submission")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var statusCode: String?
    @NSManaged public var codeContext: CodeContext?

}
