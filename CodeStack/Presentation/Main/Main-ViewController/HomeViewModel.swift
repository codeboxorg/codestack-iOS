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


protocol HomeViewModelProtocol: ViewModelType{
    
}

class HomeViewModel: HomeViewModelProtocol,Stepper{
    
    struct Input{
        var viewDidLoad: Signal<Void>
        var problemButtonEvent: Signal<ButtonType>
        var rightSwipeGesture: Observable<UIGestureRecognizer>
        var leftSwipeGesture: Observable<UIGestureRecognizer>
        var leftNavigationButtonEvent: Signal<Void>
        var recentProblemPage: Signal<Submission>
        
        var alramTapped: Observable<UIGestureRecognizer>
    }
    
    struct Output{
        var submissions: Driver<[Submission]>
    }
    
    var steps = PublishRelay<Step>()
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    private var service: TestService = NetworkService()
    
    
    //MARK: -output
    private var submissions = PublishRelay<[Submission]>()
    
    init(_ service: TestService = NetworkService()){
        self.service = service
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
        
        input.leftNavigationButtonEvent
            .withUnretained(self)
            .emit(onNext: {vm, value in
                vm.steps.accept(CodestackStep.sideShow)
            }).disposed(by: disposeBag)
        
       input.viewDidLoad
            .map{_ in self.service.request().content}
            .withUnretained(self)
            .emit(onNext: { vm, value in
                vm.submissions.accept(value)
            }).disposed(by: disposeBag)
        
        
        //추후 모델 추가 예정
        input.recentProblemPage
            .map{ _ in CodestackStep.recentSolveList }
            .emit(to: steps)
            .disposed(by: disposeBag)

        
        return Output(submissions: self.submissions.asDriver(onErrorJustReturn: []))
    }
    
}

