//
//  CodeContextMO+CoreDataProperties.swift
//  
//
//  Created by 박형환 on 11/22/23.
//
//

import Foundation
import CoreData


extension CodeContextMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CodeContextMO> {
        return NSFetchRequest<CodeContextMO>(entityName: "CodeContext")
    }

    @NSManaged public var code: String?
    @NSManaged public var language: String?
    @NSManaged public var problemID: String?

}
