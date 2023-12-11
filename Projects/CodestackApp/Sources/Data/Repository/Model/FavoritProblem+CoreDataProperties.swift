//
//  FavoritProblem+CoreDataProperties.swift
//  CodeStack
//
//  Created by 박형환 on 12/7/23.
//
//

import Foundation
import CoreData


extension FavoritProblemMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoritProblemMO> {
        return NSFetchRequest<FavoritProblemMO>(entityName: "FavoritProblem")
    }

    @NSManaged public var problemID: String?
    @NSManaged public var problemTitle: String?
    @NSManaged public var createdAt: Date?

}

extension FavoritProblemMO : Identifiable {

}
