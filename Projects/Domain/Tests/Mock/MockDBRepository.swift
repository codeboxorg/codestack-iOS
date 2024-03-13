//
//  MockDBRepository.swift
//  Domain
//
//  Created by 박형환 on 2/26/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import RxSwift
import Foundation
@testable import Domain

extension SubmissionVO {
    static var test: SubmissionVO {
        .init(id: UUID().uuidString,
              sourceCode: "#include stdio.h \n int main { \n print(\"hello world\")}",
              problem: .init(id: "1", title: "hello wolrd"),
              member: .init(username: "hyeonghwan"),
              language: .init(id: "1", name: "C", extension: ""),
              cpuTime: -1,
              memoryUsage: -1,
              statusCode: .allCases.randomElement()!,
              createdAt: Date().toString())
    }
    
    static func test(problemID: String,
                     sourceCode: String = "#include stdio.h \n int main { \n print(\"hello world\")}") -> SubmissionVO {
        .init(id: UUID().uuidString,
              sourceCode: sourceCode,
              problem: .init(id: "\(problemID)", title: "hello wolrd"),
              member: .init(username: "hyeonghwan"),
              language: .init(id: "1", name: "C", extension: ""),
              cpuTime: -1,
              memoryUsage: -1,
              statusCode: .temp,
              createdAt: Date().toString())
    }
    
    static func test(problemID: String ,statusCode: SolveStatus, date: String) -> SubmissionVO {
        .init(id: UUID().uuidString,
              sourceCode: "#include stdio.h \n int main { \n print(\"hello world\")}",
              problem: .init(id: "\(problemID)", title: "hello wolrd"),
              member: .init(username: "hyeonghwan"),
              language: .init(id: "1", name: "C", extension: ""),
              cpuTime: -1,
              memoryUsage: -1,
              statusCode: statusCode,
              createdAt: date)
    }
}

public final class MockDBRepository: DBRepository {
    
    public struct SubmissionState {
        public var submissions: [SubmissionVO]
        public var problemSubmissionState: [ProblemSubmissionStateVO]
        public var submissionCalendarState: SubmissionCalendarVO = .init(dates: [])
        public var favoriteProblemState: [FavoriteProblemVO] = []
        
        public init(submissions: [SubmissionVO], problemSubmissionState: [ProblemSubmissionStateVO]) {
            self.submissions = submissions
            self.problemSubmissionState = problemSubmissionState
        }
    }
    
    public var state: SubmissionState = SubmissionState.init(submissions: [], problemSubmissionState: [])
    
    public func fetch(_ requestType: SUB_TYPE) -> RxSwift.Single<[SubmissionVO]> {
        
        switch requestType {
        case .isExist(let problemID):
            let subs = state.submissions.filter { $0.problem.id == problemID }
            return .just(subs.sortByDate(false))
            
            
        case .is_NOT_ST_Equal_ID(_, let status):
            let sample = (0...100).map { _ in SubmissionVO.test }
            var value: [SubmissionVO] = []
            for vo in sample {
                if vo.statusCode != status {
                    value.append(vo)
                }
            }
            return .just(value)
        default:
            return .just([SubmissionVO.sample])
        }
    }
    
    public func store(submission: SubmissionVO) -> RxSwift.Single<Void> {
        state.submissions.append(submission)
        
        if submission.statusCode != .temp && submission.statusCode != .favorite {
            var calendar = state.submissionCalendarState
            let newDates = calendar.dates + [submission.createdAt]
            self.state.submissionCalendarState = SubmissionCalendarVO(dates: newDates)
        }
        
        let problemSubmissionState = state.problemSubmissionState.filter {
            let sub = $0.submissions.first!
            return sub.problem.id == submission.problem.id
        }
        
        var value = problemSubmissionState.first
        == nil 
        ? ProblemSubmissionStateVO(submissions: [])
        :
        problemSubmissionState.first!
        value.submissions.append(submission)
        
        state.problemSubmissionState.removeAll(where:  {
            $0.submissions.first!.id == value.submissions.first!.id
        })
        
        state.problemSubmissionState.append(value)
        
        return .just(())
    }
    
    public func removeAll() -> RxSwift.Single<Void> {
        state.submissions = []
        return .just(())
    }
    
    public func remove(_ requestType: SUB_TYPE) -> RxSwift.Completable {
        Completable.create { [weak self] complete in
            switch requestType {
            case .delete(let languageName, let problemID, let solveStatus):
                self?.state.submissions.removeAll(where: {
                    $0.language.name == languageName &&
                    $0.problem.id == problemID &&
                    $0.statusCode == solveStatus
                })
            default:
                fatalError()
            }
            complete(.completed)
            return Disposables.create { }
        }
    }
    
    public func update(submission: SubmissionVO, type request: SUB_TYPE) -> RxSwift.Single<Void> {
        .just(())
    }
    
    public func fetchProblemState(_ requestType: PR_SUB_ST_TYPE) -> RxSwift.Single<[ProblemSubmissionStateVO]> {
        .just(state.problemSubmissionState)
        
    }
    
    public func fetchSubmissionCalendar() -> RxSwift.Single<[SubmissionCalendarVO]> {
        .just([self.state.submissionCalendarState])
    }
    
    public func store(favoriteProblem: FavoriteProblemVO) -> RxSwift.Single<Void> {
        state.favoriteProblemState.append(favoriteProblem)
        return .just(())
    }
    
    public func fetchFavoriteProblems() -> RxSwift.Single<[FavoriteProblemVO]> {
        .just(state.favoriteProblemState)
    }
    
    public func fetchFavoriteExist(_ problemID: String) -> Single<Bool> {
        return state.favoriteProblemState.filter { $0.problemID == problemID }.count == 1
        ?
            .just(true)
        :
            .just(false)
    }
    
    public func removeFavor(_ requestType: FAV_TYPE) -> RxSwift.Completable {
        Completable.create { 
            $0(.completed)
            return Disposables.create { }
        }
    }
}
