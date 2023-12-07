//
//  ProblemSubmissionStateMO+CoreDataProperties.swift
//  CodeStack
//
//  Created by 박형환 on 11/28/23.
//
//

import Foundation
import CoreData


extension ProblemSubmissionStateMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProblemSubmissionStateMO> {
        return NSFetchRequest<ProblemSubmissionStateMO>(entityName: "ProblemSubmissionState")
    }

    @NSManaged public var submissions: NSSet?

}

// MARK: Generated accessors for submission
extension ProblemSubmissionStateMO {

    @objc(addSubmissionObject:)
    @NSManaged public func addToSubmission(_ value: SubmissionMO)

    @objc(removeSubmissionObject:)
    @NSManaged public func removeFromSubmission(_ value: SubmissionMO)

    @objc(addSubmission:)
    @NSManaged public func addToSubmission(_ values: NSSet)

    @objc(removeSubmission:)
    @NSManaged public func removeFromSubmission(_ values: NSSet)

}

extension ProblemSubmissionStateMO : Identifiable {

}
