//
//  LoginViewModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/30.
//

import Foundation
import RxFlow
import RxRelay
import RxSwift
import RxCocoa


protocol LoginViewModelProtocol: AnyObject,ViewModelType{
    func requestOAuth() throws
}

enum LoginError: Error{
    case gitOAuthError
}

class LoginViewModel: LoginViewModelProtocol,Stepper{
    var steps: PublishRelay<RxFlow.Step>
    
    struct Input{
        var loginEvent: Signal<LoginButtonType>
    }
    
    struct Output{
        
    }
    
    var disposeBag = DisposeBag()
    
    private weak var service: OAuthrizationRequest?
    
    init(service: OAuthrizationRequest?, stepper: LoginStepper){
        self.service = service
        self.steps = stepper.steps
    }
    
    func transform(input: Input) -> Output {
        input.loginEvent
            .withUnretained(self)
            .emit{ vm,type in
                switch type{
                case .apple:
                    break
                case .gitHub:
                    break
                case .email((let id, let pwd)):
                    vm.steps.accept(CodestackStep.userLoggedIn(id, pwd))
                case .none:
                    break
                }
            }.disposed(by: disposeBag)
        return Output()
    }
    
    func requestOAuth() throws {
        do {
            try service?.gitOAuthrization()
        }catch{
            throw LoginError.gitOAuthError
        }
    }
    
    
}
