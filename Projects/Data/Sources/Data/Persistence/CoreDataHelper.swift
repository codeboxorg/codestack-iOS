//
//  CoreDataHelper.swift
//  CodeStack
//
//  Created by 박형환 on 11/22/23.
//

import CoreData


protocol ManagedEntity: NSFetchRequestResult { }


extension ManagedEntity where Self: NSManagedObject {
    
    static var entityName: String {
        let nameMO = String(describing: Self.self)
        let suffixIndex = nameMO.index(nameMO.endIndex, offsetBy: -2)
        return String(nameMO[..<suffixIndex])
    }
    
    static func insertNew(in context: NSManagedObjectContext) -> Self? {
        guard let description = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            return nil
        }
        return Self.init(entity: description, insertInto: context)
    }
    
    static func newFetchRequest() -> NSFetchRequest<Self> {
        return .init(entityName: entityName)
    }
}

extension CodestackMO: ManagedEntity { }
extension SubmissionMO: ManagedEntity { }
extension CodeContextMO: ManagedEntity { }
extension LanguageMO: ManagedEntity { }
extension ProblemSubmissionStateMO: ManagedEntity { }
extension SubmissionCalendarMO: ManagedEntity { }
extension FavoritProblemMO: ManagedEntity { }


// MARK: - NSManagedObjectContext
extension NSManagedObjectContext {
    
    func configureAsReadOnlyContext() {
        automaticallyMergesChangesFromParent = true
        mergePolicy = NSRollbackMergePolicy
        undoManager = nil
        shouldDeleteInaccessibleFaults = true
    }
    
    func configureAsUpdateContext() {
        mergePolicy = NSOverwriteMergePolicy
        undoManager = nil
    }
}

// MARK: - Misc
extension NSSet {
    func toArray<T>(of type: T.Type) -> [T] {
        allObjects.compactMap { $0 as? T }
    }
}
