//
//  LanguageMO+CoreDataProperties.swift
//  CodeStack
//
//  Created by 박형환 on 11/22/23.
//
//

import Foundation
import CoreData


extension LanguageMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LanguageMO> {
        return NSFetchRequest<LanguageMO>(entityName: "Language")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var `extension`: String?

}

extension LanguageMO : Identifiable {

}
