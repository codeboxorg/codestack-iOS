//
//  HomeViewModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/08.
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow


protocol HomeViewModelProtocol: ViewModelType{
    
}

class HomeViewModel: HomeViewModelProtocol,Stepper{
    
    struct Input{
        var problemButtonEvent: Signal<ButtonType>
    }
    
    struct Output{
        
    }
    
    var steps = PublishRelay<Step>()
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    init(){
        
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
        
        return Output()
    }
    
}

class HomeStepper: Stepper{
    
    var steps = PublishRelay<Step>()
    
    var initialStep: Step{
        CodestackStep.firstHomeStep
    }
}
