//
//  OnBoardingViewModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/14.
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

struct OnBoardingViewModel: ViewModelType,Stepper{
    
    struct Input{
        var viewDidLoad: Single<Void>
    }
    
    struct Output{
        
    }
    
    var steps: PublishRelay<Step> = PublishRelay<Step>()
    
    
    var initialStep: Step {
        CodestackStep.none
    }
    

    func transform(input: Input) -> Output {
        return Output()
    }

}
