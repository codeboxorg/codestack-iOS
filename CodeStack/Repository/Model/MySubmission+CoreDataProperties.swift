//
//  MySubmission+CoreDataProperties.swift
//  
//
//  Created by 박형환 on 11/22/23.
//
//

import Foundation
import CoreData


extension MySubmission {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MySubmission> {
        return NSFetchRequest<MySubmission>(entityName: "MySubmission")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: String?

}
