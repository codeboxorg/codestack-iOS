//
//  SubmissionCalendarMO+CoreDataProperties.swift
//  CodeStack
//
//  Created by 박형환 on 12/2/23.
//
//

import Foundation
import CoreData


extension SubmissionCalendarMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubmissionCalendarMO> {
        return NSFetchRequest<SubmissionCalendarMO>(entityName: "SubmissionCalendar")
    }

    @NSManaged public var submission: NSSet?

}

// MARK: Generated accessors for submission
extension SubmissionCalendarMO {

    @objc(addSubmissionObject:)
    @NSManaged public func addToSubmission(_ value: SubmissionMO)

    @objc(removeSubmissionObject:)
    @NSManaged public func removeFromSubmission(_ value: SubmissionMO)

    @objc(addSubmission:)
    @NSManaged public func addToSubmission(_ values: NSSet)

    @objc(removeSubmission:)
    @NSManaged public func removeFromSubmission(_ values: NSSet)

}

extension SubmissionCalendarMO : Identifiable {

}
