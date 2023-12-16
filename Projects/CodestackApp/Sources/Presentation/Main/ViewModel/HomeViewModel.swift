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
import Global
import Domain


protocol HomeViewModelType: ViewModelType, Stepper, AnyObject {
    var sendSubmission: PublishRelay<SubmissionVO> { get set }
}

typealias SourceCode = String

final class HomeViewModel: HomeViewModelType {
    
    struct Input{
        var viewDidLoad: Signal<Void>
        var problemButtonEvent: Signal<ButtonType>
        var rightSwipeGesture: Observable<Void>
        var leftSwipeGesture: Observable<Void>
        var leftNavigationButtonEvent: Signal<Void>
        var recentModelSelected: Signal<SubmissionVO>
        var emptyDataButton: Signal<Void>
        var alramTapped: Observable<Void>
    }
    
    struct Output {
        var submissions: Driver<[RecentSubmission]>
    }
    
    var steps = PublishRelay<Step>()
    
    private var homeUsecase: HomeUsecase
    private var disposeBag: DisposeBag = DisposeBag()
    
    //MARK: - Input
    var sendSubmission = PublishRelay<SubmissionVO>()
    var updateSubmission = PublishRelay<SubmissionVO>()
    
    //MARK: - output
    private var submissions = PublishRelay<[RecentSubmission]>()
    
    struct Dependency {
        let homeUsecase: HomeUsecase
    }
    
    init(dependency: Dependency){
        self.homeUsecase = dependency.homeUsecase
        sendSubmissionBinding()
        updateSubmissionBinding()
    }
    
    private func sendSubmissionBinding() {
        sendSubmission
            .map{ $0 }
            .subscribe(with: self,onNext: { vm, submission in
                vm.updateSubmission.accept(submission)
            }).disposed(by: disposeBag)
    }
    
    private func updateSubmissionBinding() {
        updateSubmission
            .map { $0 }
            .withLatestFrom(submissions) { [weak self] (updatedSubmission, subs) -> [SubmissionVO] in
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
                // TODO: 확인후 변경 바람º
                let _submission: SubmissionVO = submission
                return _submission.problemVO.toProblemList(submission)
            }
            .map { CodestackStep.recentSolveList($0)}
            .emit(to: steps)
            .disposed(by: disposeBag)
        
        return Output(submissions: self.submissions.asDriver(onErrorJustReturn: []))
    }
    
    func fetchProblem(using submission: SubmissionVO) -> Signal<SubmissionVO> {
        homeUsecase.fetchProblem(using: submission)
            .asSignal(onErrorRecover: { error in
                Log.error("\(error)")
                return .just(SubmissionVO.sample)
            })
    }
    
    func fetchedSubmission() -> Signal<[SubmissionVO]> {
        homeUsecase
            .fetchSubmissionList()
            .asSignal(onErrorJustReturn: [])
    }
    
    private func updateSubmissionList(will updateSubmission: SubmissionVO,
                                      original submissions: [SubmissionVO]) -> [SubmissionVO] {
        let id = updateSubmission.problem.id
        
        let originalIDs = submissions.map(\.problem.id)
        
        let flag = originalIDs.contains(id)
        
        if flag {
            let newSubmissions: [SubmissionVO] = submissions.map {
                $0.problem.id == updateSubmission.problem.id ? updateSubmission : $0
            }
            let sortedSubmissions: [SubmissionVO] = newSubmissions.sortByDate()
            return Array(sortedSubmissions.prefix(10))
        } else {
            let array = [updateSubmission] + submissions
            return Array(array.prefix(10))
        }
    }
}
