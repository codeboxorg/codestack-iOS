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
            .emit{
                print("buttonType : \($0)")
            }.disposed(by: disposeBag)
        
        return Output()
    }
    
}
