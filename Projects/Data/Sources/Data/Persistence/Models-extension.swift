//
//  Models-extension.swift
//  CodeStack
//
//  Created by 박형환 on 11/22/23.
//


import CoreData
import Global
import Domain

protocol MapperbleProtocol {
    associatedtype PersistenceType: NSFetchRequestResult
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> PersistenceType?
    
    static func fetchRequest() -> NSFetchRequest<PersistenceType>
}
