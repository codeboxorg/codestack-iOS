//
//  Codestack+CoreDataProperties.swift
//  Data
//
//  Created by 박형환 on 3/2/24.
//  Copyright © 2024 hyeong. All rights reserved.
//
//

import Foundation
import CoreData
import Domain

extension CodestackMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CodestackMO> {
        return NSFetchRequest<CodestackMO>(entityName: "Codestack")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var sourceCode: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var language: LanguageMO?

}

extension CodestackMO : Identifiable {
    func toDomain() -> CodestackVO? {
        guard let id = self.id,
              let sourceCode = self.sourceCode,
              let name = self.name,
              let updatedAt = self.updatedAt,
              let createdAt = self.createdAt,
              let languageVO = self.language?.toDomain()
        else {
            return nil
        }
        
        return CodestackVO.init(id: id,
                                name: name,
                                sourceCode: sourceCode,
                                languageVO: languageVO,
                                updatedAt: updatedAt.toString(),
                                createdAt: createdAt.toString())
    }
}

extension CodestackVO {
    func updateMO(mo: CodestackMO) -> CodestackMO {
        mo.language?.languageID = self.languageVO.id
        mo.language?.name = self.languageVO.name
        mo.name = self.name
        mo.language?.extension = self.languageVO.extension
        mo.sourceCode = self.sourceCode
        mo.createdAt = self.createdAt.isKSTORUTC()
        mo.updatedAt = mo.updatedAt
        return mo
    }
    
    func toMO(in context: NSManagedObjectContext) -> CodestackMO? {
        guard
            let codestackMO = CodestackMO.insertNew(in: context),
            let languageMO = self.languageVO.toMO(in: context)
        else {
            return nil
        }
        
        codestackMO.id = self.id
        codestackMO.sourceCode = self.sourceCode
        codestackMO.language = languageMO
        codestackMO.name = self.name
        codestackMO.createdAt = self.createdAt.isKSTORUTC()
        codestackMO.updatedAt = self.updatedAt.isKSTORUTC()
        return codestackMO
    }
}

