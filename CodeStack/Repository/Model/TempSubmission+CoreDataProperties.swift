//
//  TempSubmission+CoreDataProperties.swift
//  
//
//  Created by 박형환 on 11/22/23.
//
//

import Foundation
import CoreData


extension TempSubmission {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TempSubmission> {
        return NSFetchRequest<TempSubmission>(entityName: "TempSubmission")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var codeContext: CodeContext?

}
