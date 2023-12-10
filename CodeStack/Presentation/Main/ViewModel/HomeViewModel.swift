//
//  HomeViewModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/08.
//

import UIKit
import RxSwift
import RxGesture
import RxCocoa
import RxFlow
import CodestackAPI


protocol HomeViewModelType: ViewModelType, Stepper, AnyObject {
    var sendSubmission: PublishRelay<Submission> { get set }
}

typealias SourceCode = String

final class HomeViewModel: HomeViewModelType {
    
    struct Input{
        var viewDidLoad: Signal<Void>
        var problemButtonEvent: Signal<ButtonType>
        var rightSwipeGesture: Observable<Void>
        var leftSwipeGesture: Observable<Void>
        var leftNavigationButtonEvent: Signal<Void>
        var recentModelSelected: Signal<Submission>
        var emptyDataButton: Signal<Void>
        var alramTapped: Observable<Void>
    }
    
    struct Output {
        var submissions: Driver<[RecentSubmission]>
    }
    
    var steps = PublishRelay<Step>()
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    private var service: WebRepository
    private var repository: DBRepository
    
    //MARK: - Input
    var sendSubmission = PublishRelay<Submission>()
    var updateSubmission = PublishRelay<Submission>()
    
    //MARK: - output
    private var submissions = PublishRelay<[RecentSubmission]>()
    
    struct Dependency {
        let repository: DBRepository
        let service: WebRepository
    }
    
    init(dependency: Dependency){
        self.service = dependency.service
        self.repository = dependency.repository
        sendSubmissionBinding()
        updateSubmissionBinding()
    }
    
    private func sendSubmissionBinding(){
        sendSubmission
            .map{ $0 }
            .subscribe(with: self,onNext: { vm, submission in
                vm.updateSubmission.accept(submission)
            }).disposed(by: disposeBag)
    }
    
    private func updateSubmissionBinding() {
        updateSubmission
            .map { $0 }
            .withLatestFrom(submissions) { [weak self] (updatedSubmission, subs) -> [Submission] in
                guard let self else { return [] }
                let originalSubmissions = subs.flatMap { $0.items }
                return self.updateSubmissionList(will: updatedSubmission, original: originalSubmissions)
            }.map {  $0.toRecentModels() }
            .subscribe(with: self, onNext: { vm, value in
                vm.submissions.accept(value)
            }).disposed(by: disposeBag)
    }
    
    
    func transform(input: Input) -> Output {
        input.problemButtonEvent
            .withUnretained(self)
            .emit{ vm,type in
                switch type{
                case .today_problem(let step):
                    vm.steps.accept(step ?? .fakeStep)
                case .recommand_problem(let step):
                    vm.steps.accept(step ?? .fakeStep)
                default:
                    vm.steps.accept(CodestackStep.fakeStep)
                }
            }.disposed(by: disposeBag)
        
        input.rightSwipeGesture
            .withUnretained(self)
            .subscribe(onNext: {vm,  _ in
                vm.steps.accept(CodestackStep.sideShow)
            }).disposed(by: disposeBag)
        
        input.leftSwipeGesture
            .withUnretained(self)
            .subscribe(onNext: {vm, value in
                vm.steps.accept(CodestackStep.sideDissmiss)
            }).disposed(by: disposeBag)
        
        input.alramTapped
            .subscribe(with: self,onNext: { vm , value in
                vm.steps.accept(CodestackStep.historyflow)
            }).disposed(by: disposeBag)
        
        input.emptyDataButton
            .emit(with: self, onNext: { vm, _ in
                vm.steps.accept(CodestackStep.problemList)
            }).disposed(by: disposeBag)
        
        input.leftNavigationButtonEvent
            .withUnretained(self)
            .emit(onNext: {vm, value in
                vm.steps.accept(CodestackStep.sideShow)
            }).disposed(by: disposeBag)
        
        input.viewDidLoad
            .withUnretained(self)
            .flatMap { vm, _ in vm.fetchedSubmission() }
            .withUnretained(self)
            .emit(onNext: { vm, value in
                if value.isEmpty{
                    Log.debug("value isEmpty")
                }
                vm.submissions.accept(value.toRecentModels())
            }).disposed(by: disposeBag)
        
        //            repository.remove()
        //                .subscribe {
        //                    Log.debug("delete")
        //                }
        
        //        repository.fetch(.default)
        //            .subscribe(onSuccess: {value in
        //                let value = value.compactMap(\.id)
        //                Log.debug("problemState Value : \(value)")
        //            })
        
        //        repository.fetchProblemStateSubmission()
        //            .subscribe(onSuccess: {value in
        //                Log.debug("problemState Value : \(value)")
        //            })
        
        //추후 모델 추가 예정
        input.recentModelSelected
            .withUnretained(self)
            .flatMapLatest { vm, submission in
                return vm.fetchProblem(using: submission)
            }
            .compactMap { submission in
                let _submission: Submission = submission
                return _submission.problem?.toProblemList(submission)
            }
            .map { CodestackStep.recentSolveList($0)}
            .emit(to: steps)
            .disposed(by: disposeBag)
        
        return Output(submissions: self.submissions.asDriver(onErrorJustReturn: []))
    }
    
    func fetchProblem(using submission: Submission) -> Signal<Submission> {
        service
            .getProblemByID(query: GetProblemByIdQuery(id: submission.problem!.id))
            .map { value in Submission(_problem: value) }
            .map { sub in
                var fetchedSubmission = sub
                fetchedSubmission.id = submission.id
                fetchedSubmission.sourceCode = submission.sourceCode
                fetchedSubmission.language = submission.language
                return fetchedSubmission
            }
            .asSignal(onErrorRecover: { error in
                var submission = submission
                return .just(submission.ifNetworkErorr())
            })
    }
    
    func fetchedSubmission() -> Signal<[Submission]> {
        repository
            .fetchProblemState()
            .map { problemState in
                if let state = problemState.first {
                    return state
                        .submissions
                        .sorted(by: { s1,s2 in
                            if let createdAt1 = s1.createdAt?.toDateKST(),
                               let createdAt2 = s2.createdAt?.toDateKST() {
                                return createdAt1 > createdAt2
                            }
                            return false
                        })
                } else {
                    return []
                }
            }
            .asSignal(onErrorJustReturn: [])
    }
    
    private func updateSubmissionList(will updateSubmission: Submission,
                                      original submissions: [Submission]) -> [Submission] {
        guard
            let id = updateSubmission.problem?.id
        else {
            return submissions
        }
        
        let originalIDs = submissions.compactMap(\.problem?.id)
        
        let flag = originalIDs.contains(id)
        
        if flag {
            let newSubmissions: [Submission] = submissions.map {
                $0.problem?.id == updateSubmission.problem?.id ? updateSubmission : $0
            }
            let sortedSubmissions: [Submission] = newSubmissions.sorted(by: { first, second in
                if let date1 = first.createdAt?.toDateKST(),
                   let date2 = second.createdAt?.toDateKST() {
                    return date1 > date2
                }
                return true
            })
            return Array(sortedSubmissions.prefix(10))
        } else {
            let array = [updateSubmission] + submissions
            return Array(array.prefix(10))
        }
    }
}
