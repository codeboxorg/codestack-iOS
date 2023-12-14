//
//  FavoritProblem+CoreDataProperties.swift
//  CodeStack
//
//  Created by 박형환 on 12/7/23.
//
//

import Foundation
import CoreData
import Domain

extension FavoritProblemMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoritProblemMO> {
        return NSFetchRequest<FavoritProblemMO>(entityName: "FavoritProblem")
    }

    @NSManaged public var problemID: String?
    @NSManaged public var problemTitle: String?
    @NSManaged public var createdAt: Date?

}

extension FavoritProblemMO : Identifiable {
    
    func toDomain() -> FavoriteProblemVO? {
        guard
        let problemID = self.problemID,
        let problemTitle = self.problemTitle,
        let createdAt = self.createdAt
        else {
            return nil
        }
        return FavoriteProblemVO(problemID: problemID,
                                 problmeTitle: problemTitle,
                                 createdAt: createdAt)
    }
}

extension FavoriteProblemVO {
    func toMO(in context: NSManagedObjectContext) -> FavoritProblemMO? {
        let favoritProblemMO = FavoritProblemMO.insertNew(in: context)
        favoritProblemMO?.problemID = self.problemID
        favoritProblemMO?.problemTitle = self.problmeTitle
        favoritProblemMO?.createdAt = self.createdAt
        return favoritProblemMO
    }
}
