//
//  Models-extension.swift
//  CodeStack
//
//  Created by 박형환 on 11/22/23.
//


import CoreData
import Global
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

extension CodeContext: MapperbleProtocol {
    typealias PersistenceType = CodeContextMO
    
    static func fetchRequest() -> NSFetchRequest<CodeContextMO> {
        CodeContextMO.fetchRequest()
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> CodeContextMO? {
        let codeContextMO = CodeContextMO.insertNew(in: context)
        codeContextMO?.code = self.code
        codeContextMO?.problemID = self.problemID
        codeContextMO?.problemTitle = self.problemTitle
        return codeContextMO
    }
    
    init?(managedContext: CodeContextMO) {
        self.init(code: managedContext.code,
                  problemID: managedContext.problemID,
                  problemTitle: managedContext.problemTitle)
    }
}

extension Language: MapperbleProtocol {
    typealias PersistenceType = LanguageMO
    
    static func fetchRequest() -> NSFetchRequest<PersistenceType> {
        LanguageMO.fetchRequest()
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> LanguageMO? {
        let languageMO = LanguageMO.insertNew(in: context)
        languageMO?.languageID = self.id
        languageMO?.extension = self._extension
        languageMO?.name = self.name
        return languageMO
    }
    
    init?(managedContext: LanguageMO) {
        guard
            let id = managedContext.languageID,
            let name = managedContext.name,
            let `extension` = managedContext.extension
        else {
            return nil
        }
        self.init(id: id, name: name, _extension: `extension`)
    }
}

extension FavoriteProblem: MapperbleProtocol {

    func store(in context: NSManagedObjectContext) -> FavoritProblemMO? {
        guard let favoriteMO = FavoritProblemMO.insertNew(in: context) else { return nil }
        favoriteMO.problemID = self.problemID
        favoriteMO.problemTitle = self.problmeTitle
        favoriteMO.createdAt = self.createdAt
        return favoriteMO
    }
    
    static func fetchRequest() -> NSFetchRequest<FavoritProblemMO> {
        FavoritProblemMO.fetchRequest()
    }
    
    typealias PersistenceType = FavoritProblemMO
    
    init?(managedContext: FavoritProblemMO) {
        guard
            let createdAt = managedContext.createdAt,
            let problemID = managedContext.problemID,
            let problemTitle = managedContext.problemTitle
        else {
            return nil
        }
        self.init(problemID: problemID, problmeTitle: problemTitle, createdAt: createdAt)
    }
}

struct ProblemSubmissionState {
    var submissions: [Submission]
}

extension SubmissionCalendar: MapperbleProtocol {
    typealias PersistenceType = SubmissionCalendarMO
    
    
    init?(managedContext: SubmissionCalendarMO) {
        guard let submissionSet = managedContext.submission else { return nil }
        
        let _submissions =
        submissionSet
            .toArray(of: SubmissionMO.self)
            .compactMap { Submission(managedContext: $0) }
        
        self.dates = _submissions.compactMap(\.createdAt)
    }
    
    func store(in context: NSManagedObjectContext) -> SubmissionCalendarMO? {
        return nil
    }
    
    static func fetchRequest() -> NSFetchRequest<SubmissionCalendarMO> {
        SubmissionCalendarMO.newFetchRequest()
    }
}



extension ProblemSubmissionState: MapperbleProtocol {
    
    typealias PersistenceType = ProblemSubmissionStateMO
    
    static func fetchRequest() -> NSFetchRequest<PersistenceType> {
        ProblemSubmissionStateMO.fetchRequest()
    }
    
    init?(managedContext: ProblemSubmissionStateMO) {
        guard let submissionSet = managedContext.submissions else { return nil }
        
        let _submissions =
        submissionSet
            .toArray(of: SubmissionMO.self)
            .compactMap { Submission(managedContext: $0) }
        
        self.submissions = _submissions
    }
    
    func store(in context: NSManagedObjectContext) -> ProblemSubmissionStateMO? {
        guard let problemSubmissionMO = ProblemSubmissionStateMO.insertNew(in: context) else { return nil }
        
        problemSubmissionMO.submissions = self.submissions.compactMap { $0.store(in: context) } as? NSSet
        
        return problemSubmissionMO
    }
}

extension Submission: MapperbleProtocol {
    typealias PersistenceType = SubmissionMO
    
    static func fetchRequest() -> NSFetchRequest<PersistenceType> {
        SubmissionMO.fetchRequest()
    }
    
    func store(in context: NSManagedObjectContext) -> SubmissionMO? {
        guard
            let submissionMO = SubmissionMO.insertNew(in: context),
            let language = self.language,
            let languageMO = language.store(in: context)
        else {
            return nil
        }
    
        let codeContext = CodeContext(code: self.sourceCode,
                                      problemID: self.problem?.id,
                                      problemTitle: self.problem?.title)
        guard let codeContextMO = codeContext.store(in: context) else {
            return nil }
        
        submissionMO.createdAt = self.createdAt?.toDateKST()
        submissionMO.id = self.id
        submissionMO.statusCode = self.statusCode
        submissionMO.codeContext = codeContextMO
        submissionMO.language = languageMO
        
        languageMO.submission = submissionMO
        codeContextMO.submission = submissionMO
        
        return submissionMO
    }
    
    init?(managedContext: SubmissionMO) {
        guard 
            let id = managedContext.id,
            let statusCode = managedContext.statusCode,
            let createdAt = managedContext.createdAt,
            let codeContextMO = managedContext.codeContext,
            let codeContext = CodeContext(managedContext: codeContextMO),
            let problemID = codeContext.problemID,
            let problemTitle = codeContext.problemTitle,
            let languageMO = managedContext.language,
            let language = Language(managedContext: languageMO)
        else {
            return nil
        }
    
        self.init(id: id,
                  sourceCode: codeContext.code,
                  problem: Problem(id: problemID, title: problemTitle),
                  member: nil,
                  language: language,
                  cpuTime: nil,
                  memoryUsage: nil,
                  statusCode: statusCode,
                  createdAt: createdAt.toString())
    }
}
