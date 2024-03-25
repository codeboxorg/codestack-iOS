//
//  EditorType.swift
//  CodestackApp
//
//  Created by 박형환 on 4/24/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import Domain


protocol EditorTypeProtocol {
    func getDefaultLanguage() -> [LanguageVO]
    func getSeletedLanguage() -> LanguageVO
    func getProblemList()     -> ProblemListItemModel
    func getCodestackVO()     -> CodestackVO
    func getSubmissionID()    -> String
    func isProblemSolve()     -> Bool
    func isOnlyEditor()       -> Bool
    func getProblemVO()       -> ProblemVO
    var problemID:      String { get }
    var problemTitle:   String { get }
    var problemContext: String { get }
}

extension EditorTypeProtocol {
    func getDefaultLanguage() -> [LanguageVO] { [] }
    func getSeletedLanguage() -> LanguageVO { .default }
    func getProblemList()     -> ProblemListItemModel { .mock }
    func getCodestackVO()     -> CodestackVO { .mock }
    func getSubmissionID()    -> String { "" }
    func isProblemSolve()     -> Bool { false }
    func isOnlyEditor()       -> Bool { false }
    func getProblemVO()       -> ProblemVO { .sample }
    
    var problemID: String { "" }
    var problemTitle: String { "" }
    var problemContext: String { "" }
}

struct DefaultEditor: EditorTypeProtocol { }

struct ProblemSolveEditor: EditorTypeProtocol {
    var problemVO: ProblemVO
    var submissionVO: SubmissionVO?
    
    init(problemVO: ProblemVO = .sample, submissionVO: SubmissionVO? = nil) {
        self.problemVO = problemVO
        self.submissionVO = submissionVO
    }
    
    func getDefaultLanguage() -> [LanguageVO] {
        problemVO.languages
    }
    
    func getSeletedLanguage() -> LanguageVO {
        submissionVO?.language ?? .default
    }
    
    func getProblemList()     -> ProblemListItemModel {
        problemVO.toProblemList(submissionVO)
    }
    
    func getSubmissionID()    -> String {
        if let submissionVO { return submissionVO.id }
        else { return UUID().uuidString }
    }
    
    func getProblemVO()       -> ProblemVO { problemVO }
    
    func isProblemSolve()     -> Bool { true }
    
    var problemID: String { problemVO.id }
    var problemTitle: String { problemVO.title }
    var problemContext: String { problemVO.context }
}

struct CodeEditor: EditorTypeProtocol {
    var codestackVO: CodestackVO
    var language: LanguageVO
    
    init(codestackVO: CodestackVO, language: LanguageVO) {
        self.codestackVO = codestackVO
        self.language = language
    }
    
    func getCodestackVO()     -> CodestackVO {
        codestackVO
    }
    
    func getDefaultLanguage() -> [LanguageVO] { [language] }
    
    func isOnlyEditor() -> Bool { true }
}

//struct ProblemSolve
enum EditorType: EditorTypeProtocol {
    case problemSolve(ProblemVO, SubmissionVO?)
    case onlyEditor(CodestackVO)
    case none
}


//let submissionID
//= if case let .onlyEditor(vo) = editorType {
//    vo.id
//} else if case let .problemSolve(problemVO, submissionVO) = editorType {
//    submissionVO?.id ?? UUID().uuidString
//} else {
//    UUID().uuidString
//}
//container.register(CodeEditorViewController.self) { resolver, editorType in
//    let viewModel = resolver.resolve(CodeEditorViewModel.self)!
//    let reactor = resolver.resolve(CodeEditorReactor.self)!
//    let dp = CodeEditorViewController.Dependency.init(viewModel: viewModel,
//                                                      editorReactor: reactor,
//                                                      editorType: editorType)
//    return CodeEditorViewController.create(with: dp)
//}
//
//container.register(CodeEditorViewController.self) { resolver, problemVO in
//    let viewModel = resolver.resolve(CodeEditorViewModel.self)!
//    let reactor = resolver.resolve(CodeEditorReactor.self)!
//    let dp = CodeEditorViewController.Dependency.init(viewModel: viewModel,
//                                                      editorReactor: reactor,
//                                                      editorType: .problemSolve(problemVO))
//    return CodeEditorViewController.create(with: dp)
//}
