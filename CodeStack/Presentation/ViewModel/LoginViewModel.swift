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
}

class LoginViewModel: LoginViewModelProtocol,Stepper{
    var steps: PublishRelay<RxFlow.Step>
    
    struct Input{
        var loginEvent: Signal<LoginButtonType>
    }
    
    struct Output{
        var loading: Driver<Bool>
    }
    
    var disposeBag = DisposeBag()
    
    
    private weak var service: OAuthrizationRequest?
    
    init(service: OAuthrizationRequest?, stepper: LoginStepper){
        self.service = service
        self.steps = stepper.steps
        (self.service as? LoginService)?.loginViewModel = self
        
        testSubject
            .flatMapLatest{ Observable.just($0) }
            .materialize()
            .subscribe(onNext: { value in
                print(value)
            }).disposed(by: disposeBag)
        
        
      
        
    }
    
    
    private var loginFailAlert: PublishSubject<Bool> = PublishSubject<Bool>()
    private var loginLoadingEvent = PublishRelay<Bool>()

    
    private var testSubject: PublishSubject<Int> = PublishSubject<Int>()
    
    
    var value: Int = 0
    func transform(input: Input) -> Output {
        input.loginEvent
            .withUnretained(self)
            .do(onNext: { [weak self] _ in
                guard let self else {return}
//                self.loginLoadingEvent.accept(true)
            })
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
                    vm.value += 1
                    vm.testSubject.onNext(vm.value)
                    vm.testSubject.onNext(vm.value)
                    #if DEBUG
//                    vm.requestAuth(id: id, pwd: pwd)
                    #endif
                case .none:
                    break
                }
            }.disposed(by: disposeBag)
        return Output(loading: loginLoadingEvent.asDriver(onErrorJustReturn: false))
    }
    
    func requestOAuth() throws {
        do {
            try service?.gitOAuthrization()
        }catch{
            throw LoginError.gitOAuthError
        }
    }

    
    var gitDisposable: Disposable?
    
    
    func oAuthComplte(apple token: AppleToken){
        _ = service?
            .request(with: token)
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
            .do(onNext: { [weak self] _ in
                self?.loginLoadingEvent.accept(false)
            },onError: { [weak self] _ in
                self?.loginLoadingEvent.accept(false)
            })
            .subscribe(with: self,onSuccess: {owner, token in
                owner.signUp(access: token.accessToken, refresh: token.refreshToken)
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
                self?.loginLoadingEvent.accept(false)
            },onError: { [weak self] _ in
                self?.loginLoadingEvent.accept(false)
            })
            .subscribe(with: self,onSuccess: {owner, token in
                owner.signUp(access: token.accessToken, refresh: token.refreshToken)
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
                self?.loginLoadingEvent.accept(false)
            },onError: { [weak self] _ in
                self?.loginLoadingEvent.accept(false)
            })
            .subscribe(with: self,onSuccess: { owner, token in
                
             ApolloService.shared.request(header: token.accessToken)
                owner.signUp(access: token.accessToken, refresh: token.refreshToken)
            },onError: { owner , err in
                Log.error(err)
            },onCompleted: { _ in
                Log.debug("complte")
            },onDisposed: { _ in
                Log.debug("disposed")
            })
    }
    
    
    private func signUp(access t1: String, refresh t2: String){
        KeychainItem.saveTokens(access: t1, refresh: t2)
        steps.accept(CodestackStep.userLoggedIn(nil, nil))
    }
}
