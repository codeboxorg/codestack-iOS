//
//  SubmissionCalendarsMO-extension.swift
//  CodeStack
//
//  Created by 박형환 on 12/2/23.
//

import CoreData



extension SubmissionCalendarMO {
    
    static func fetchSubmissionCalendarMO(context: NSManagedObjectContext) throws -> SubmissionCalendarMO? {
        let calendarMOs = try context.fetch(SubmissionCalendarMO.fetchRequest())
        var _calendarMO: SubmissionCalendarMO?
        
        if calendarMOs.count == 0 {
            _calendarMO = SubmissionCalendarMO.insertNew(in: context)
            return _calendarMO
        }
        return calendarMOs.first!
    }
}
