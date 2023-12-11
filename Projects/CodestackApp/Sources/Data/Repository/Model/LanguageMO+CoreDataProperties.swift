//
//  LanguageMO+CoreDataProperties.swift
//  CodeStack
//
//  Created by 박형환 on 12/5/23.
//
//

import Foundation
import CoreData


extension LanguageMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LanguageMO> {
        return NSFetchRequest<LanguageMO>(entityName: "Language")
    }

    @NSManaged public var `extension`: String?
    @NSManaged public var languageID: String?
    @NSManaged public var name: String?
    @NSManaged public var submission: SubmissionMO?

}

extension LanguageMO : Identifiable {

}
