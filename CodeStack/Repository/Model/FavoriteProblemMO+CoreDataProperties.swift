//
//  FavoriteProblemMO+CoreDataProperties.swift
//  CodeStack
//
//  Created by 박형환 on 11/22/23.
//
//

import Foundation
import CoreData


extension FavoriteProblemMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteProblemMO> {
        return NSFetchRequest<FavoriteProblemMO>(entityName: "FavoriteProblem")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var problemID: String?
    @NSManaged public var problemTitle: String?
}

extension FavoriteProblemMO : Identifiable {

}
