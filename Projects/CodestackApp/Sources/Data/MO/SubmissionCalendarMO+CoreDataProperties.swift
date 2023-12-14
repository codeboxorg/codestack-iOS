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

    
    func toDomain() -> SubmissionCalendarVO? {
        guard let submissionSet = self.submission else { return nil }
        
        let _submissions =
        submissionSet
            .toArray(of: SubmissionMO.self)
            .compactMap { value in value.toDomain() }
        
        return SubmissionCalendarVO(dates: _submissions.map(\.createdAt))
    }
}

extension SubmissionCalendarVO {
    func toMO() -> SubmissionCalendarMO? {
        return nil
    }
}
