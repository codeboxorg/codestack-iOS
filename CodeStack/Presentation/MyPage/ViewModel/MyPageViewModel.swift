//
//  MyPageViewModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/16.
//

import Foundation
import RxFlow
import RxSwift
import RxCocoa

class MyPageViewModel: ViewModelType,Stepper{
    
    struct Input{
        
    }
    
    struct Output{
        
    }
    
    var steps = PublishRelay<Step>()
    
    init(){
        
    }
    
    
    func transform(input: Input) -> Output {
        return Output()
    }
}
