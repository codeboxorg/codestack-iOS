//
//  CodeContextMO+CoreDataProperties.swift
//  CodeStack
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
    @NSManaged public var problemID: String?
    @NSManaged public var problemTitle: String?
    @NSManaged public var language: LanguageMO
}

extension CodeContextMO : Identifiable {

}
