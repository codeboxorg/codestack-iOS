//
//  CodeContext+CoreDataProperties.swift
//  
//
//  Created by 박형환 on 11/22/23.
//
//

import Foundation
import CoreData


extension CodeContext {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CodeContext> {
        return NSFetchRequest<CodeContext>(entityName: "CodeContext")
    }

    @NSManaged public var code: String?
    @NSManaged public var language: String?
    @NSManaged public var problemID: String?

}
