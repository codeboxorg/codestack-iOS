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
    
    /// Git Auth Complte
    /// - Parameter code: git Authorize code
    func oAuthComplete(code: String)
    
    func oAuthComplte(apple token: AppleToken)
}

enum LoginError: Error{
    case gitOAuthError
    case timeOut
}

class LoginViewModel: LoginViewModelProtocol,Stepper{
    var steps: PublishRelay<RxFlow.Step>
    
    struct Input{
        var loginEvent: Signal<LoginButtonType>
        var registerEvent: Signal<Void>
    }
    
    struct Output{
        var loading: Driver<Result<Bool,Error>>
    }
    
    var disposeBag = DisposeBag()
    
    
    private weak var service: OAuthrizationRequest?
    
    init(service: OAuthrizationRequest?, stepper: LoginStepper){
        self.service = service
        self.steps = stepper.steps
        (self.service as? LoginService)?.loginViewModel = self
    }
    
    
    private var loginFailAlert: PublishSubject<Bool> = PublishSubject<Bool>()
    private var loginLoadingEvent = PublishRelay<Result<Bool,Error>>()

    
    
    var value: Int = 0
    func transform(input: Input) -> Output {
        input.loginEvent
            .withUnretained(self)
            .emit{ vm,type in
                switch type{
                case .apple:
                    break
                case .gitHub:
                    do{
                        try vm.service?.gitOAuthrization()
                    }catch{
                        Log.error("github 로그인 실패 : \(error)")
                    }
                case .email((let id, let pwd)):
                    vm.loginLoadingEvent.accept(.success(true))
                    #if DEBUG
//                    vm.steps.accept(CodestackStep.userLoggedIn(nil, nil))
                    vm.requestAuth(id: id, pwd: pwd)
                    #else
                    
                    #endif
                case .none:
                    break
                }
            }.disposed(by: disposeBag)
        
        
        input.registerEvent
            .map{_ in CodestackStep.register}
            .emit(to: steps)
            .disposed(by: disposeBag)
        
        return Output(loading: loginLoadingEvent.asDriver(onErrorJustReturn: .failure(LoginError.timeOut)))
    }
    
    
    func requestOAuth() throws {
        do {
            try service?.gitOAuthrization()
        }catch{
            throw LoginError.gitOAuthError
        }
    }

    
    func oAuthComplte(apple token: AppleToken){
        _ = service?
            .request(with: token)
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
            .do(onNext: { [weak self] _ in
                self?.loginLoadingEvent.accept(.success(false))
            },onError: { [weak self] _ in
                self?.loginLoadingEvent.accept(.failure(LoginError.timeOut))
            })
            .subscribe(with: self,onSuccess: {owner, token in
                
                owner.signUp(token: token)
            },onError: { owner , err in
                Log.error(err)
            },onCompleted: { _ in
                Log.error("complte")
            },onDisposed: { _ in
                Log.error("disposed")
            })
    }
    
    /// gitHub OAuh 가 끝나고 다시 서버로 token 요청하는 함수
    /// - Parameter code: github code
    func oAuthComplete(code: String){
        _ = service?
            .request(with: GitCode(code: code), provider: .github)
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
            .do(onNext: { [weak self] _ in
                self?.loginLoadingEvent.accept(.success(false))
            },onError: { [weak self] err in
                Log.debug(err)
                self?.loginLoadingEvent.accept(.failure(LoginError.timeOut))
            })
            .subscribe(with: self,onSuccess: {owner, token in
                owner.signUp(token: token)
            },onError: { owner , err in
                Log.error(err)
            },onCompleted: { _ in
                Log.error("complte")
            },onDisposed: { _ in
                Log.error("disposed")
            })
    }
    
    private func requestAuth(id: String, pwd: String){
        _ = service?.request(name: id, password: pwd)
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
            .do(onNext: { [weak self] _ in
                self?.loginLoadingEvent.accept(.success(false))
            },onError: { [weak self] _ in
                self?.loginLoadingEvent.accept(.failure(LoginError.timeOut))
            })
            .subscribe(with: self,onSuccess: { owner, token in
//             ApolloService.shared.request(header: token.accessToken)
                owner.signUp(token: token)
            },onError: { owner , err in
                Log.error(err)
            },onCompleted: { _ in
                Log.debug("complte")
            },onDisposed: { _ in
                Log.debug("disposed")
            })
    }
    
    
    private func signUp(token: CodestackResponseToken){
        Log.debug("\(token.accessToken) + \(token.refreshToken)")
        
        KeychainItem.saveTokens(access: token.accessToken, refresh: token.refreshToken)
        
        UserDefaults.standard.set(token.expiresIn, forKey: "expiresIn")
        UserDefaults.standard.set(token.tokenType, forKey: "tokenType")
        
        steps.accept(CodestackStep.userLoggedIn(nil, nil))
    }
}
