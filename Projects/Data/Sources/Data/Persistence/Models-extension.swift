//
//  Models-extension.swift
//  CodeStack
//
//  Created by 박형환 on 11/22/23.
//


import CoreData
import Global
import Domain

protocol ManagedEntity: NSFetchRequestResult { }

extension SubmissionMO: ManagedEntity { }
extension CodeContextMO: ManagedEntity { }
extension LanguageMO: ManagedEntity { }
extension ProblemSubmissionStateMO: ManagedEntity { }
extension SubmissionCalendarMO: ManagedEntity { }
extension FavoritProblemMO: ManagedEntity { }

protocol MapperbleProtocol {
    associatedtype PersistenceType: NSFetchRequestResult
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> PersistenceType?
    
    static func fetchRequest() -> NSFetchRequest<PersistenceType>
}

//extension FavoriteProblem: MapperbleProtocol {
//
//    func store(in context: NSManagedObjectContext) -> FavoritProblemMO? {
//        guard let favoriteMO = FavoritProblemMO.insertNew(in: context) else { return nil }
//        favoriteMO.problemID = self.problemID
//        favoriteMO.problemTitle = self.problmeTitle
//        favoriteMO.createdAt = self.createdAt
//        return favoriteMO
//    }
//    
//    static func fetchRequest() -> NSFetchRequest<FavoritProblemMO> {
//        FavoritProblemMO.fetchRequest()
//    }
//    
//    typealias PersistenceType = FavoritProblemMO
//    
//    init?(managedContext: FavoritProblemMO) {
//        guard
//            let createdAt = managedContext.createdAt,
//            let problemID = managedContext.problemID,
//            let problemTitle = managedContext.problemTitle
//        else {
//            return nil
//        }
//        self.init(problemID: problemID, problmeTitle: problemTitle, createdAt: createdAt)
//    }
//}
//
//struct ProblemSubmissionState {
//    var submissions: [SubmissionVO]
//}
//
//extension SubmissionCalendar: MapperbleProtocol {
//    typealias PersistenceType = SubmissionCalendarMO
//    
//    
//    init?(managedContext: SubmissionCalendarMO) {
//        guard let submissionSet = managedContext.submission else { return nil }
//        
//        let _submissions =
//        submissionSet
//            .toArray(of: SubmissionMO.self)
//            .compactMap { $0.toDomain() }
//        
//        self.dates = _submissions.map(\.createdAt)
//    }
//    
//    func store(in context: NSManagedObjectContext) -> SubmissionCalendarMO? {
//        return nil
//    }
//    
//    static func fetchRequest() -> NSFetchRequest<SubmissionCalendarMO> {
//        SubmissionCalendarMO.newFetchRequest()
//    }
//}
//
//
//
//extension ProblemSubmissionState: MapperbleProtocol {
//    
//    typealias PersistenceType = ProblemSubmissionStateMO
//    
//    static func fetchRequest() -> NSFetchRequest<PersistenceType> {
//        ProblemSubmissionStateMO.fetchRequest()
//    }
//    
//    init?(managedContext: ProblemSubmissionStateMO) {
//        guard let submissionSet = managedContext.submissions else { return nil }
//        
//        let _submissions =
//        submissionSet
//            .toArray(of: SubmissionMO.self)
//            .compactMap { $0.toDomain() }
//            //.compactMap { Submission(managedContext: $0) }
//        
//        self.submissions = _submissions
//    }
//    
//    func store(in context: NSManagedObjectContext) -> ProblemSubmissionStateMO? {
//        guard let problemSubmissionMO = ProblemSubmissionStateMO.insertNew(in: context) else { return nil }
//        
//        problemSubmissionMO.submissions = self.submissions.compactMap { $0.toMO(in:) } as? NSSet
//        
//        return problemSubmissionMO
//    }
//}
