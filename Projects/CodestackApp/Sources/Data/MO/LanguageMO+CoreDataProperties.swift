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
    func toDomain() -> LanguageVO? {
        guard
            let name = self.name,
            let languageID = self.languageID,
            let `extension` = self.extension
        else {
            return nil
        }
        return LanguageVO(id: languageID, name: name, extension: `extension`)
    }
}

extension LanguageVO {
    
    func toMO(in context: NSManagedObjectContext) -> LanguageMO? {
        let languageMO = LanguageMO.insertNew(in: context)
        languageMO?.languageID = self.id
        languageMO?.name = self.name
        languageMO?.extension = self.extension
        return languageMO
    }
}
