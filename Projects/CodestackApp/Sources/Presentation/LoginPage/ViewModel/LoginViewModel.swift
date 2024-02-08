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
import Domain

enum LoginError: Error{
    case gitOAuthError
    case timeOut
}

class LoginViewModel: /*LoginViewModelProtocol*/ Stepper{
    
    var steps: PublishRelay<RxFlow.Step>
    
    struct Input{
        var loginEvent: Signal<LoginButtonType>
        var registerEvent: Signal<Void>
    }
    
    struct Output{
        var loading: Driver<Result<Bool,Error>>
    }
    
    struct Dependency {
        let authUsecase: AuthUsecase
        let stepper: LoginStepper
    }
    
    private var disposeBag = DisposeBag()
    private let authUsecase: AuthUsecase
    
    init(dependency: Dependency){
        self.authUsecase = dependency.authUsecase
        self.steps = dependency.stepper.steps
        
        // TODO: 해결 해야됌
        // (self.loginService as? LoginService)?.loginViewModel = self
    }
    
    private var loginFailAlert: PublishSubject<Bool> = PublishSubject<Bool>()
    private var loginLoadingEvent = PublishRelay<Result<Bool,Error>>()
    
    var value: Int = 0
    
    func transform(input: Input) -> Output {
      
        loginEventBinding(login: input.loginEvent)
        registerBinding(register: input.registerEvent)
        
        return Output(loading: loginLoadingEvent.asDriver(onErrorJustReturn: .failure(LoginError.timeOut)))
    }
    
    
    private func loginEventBinding(login event: Signal<LoginButtonType>) {
        event
            .withUnretained(self)
            .emit{ vm,type in
                switch type {
                case .apple:
                    break
                case .gitHub:
                    do{
                        try vm.authUsecase.gitOAuthrization()
                    }catch{
                        // Log.error("github 로그인 실패 : \(error)")
                    }
                case .email((let id, let pwd)):
                    
                    // MARK: 익명 로그인
                    vm.loginLoadingEvent.accept(.success(true))
                    // vm.requestFirebaseAnonymousAuth()
                    
                    vm.requestFirebaseAuth(email: id, password: pwd)
                    
                    #if DEBUG
                    // TODO: 502 Bad Gate Way
//                    vm.loginLoadingEvent.accept(.success(true))
//                    vm.requestAuth(id: id, pwd: pwd)
                    #endif
                case .none:
                    break
                }
            }.disposed(by: disposeBag)
    }
    
    private func registerBinding(register event: Signal<Void>) {
        event
            .map{_ in CodestackStep.register}
            .emit(to: steps)
            .disposed(by: disposeBag)
    }
    
    
    func requestOAuth() throws {
//        do {
//            try loginService.gitOAuthrization()
//        }catch{
//            throw LoginError.gitOAuthError
//        }
    }
    
    func requestFirebaseAuth(email: String, password: String) {
        authUsecase
            .firebaseAuth(email: email, pwd: password)
            .do(onError: { [weak self] _ in
                self?.loginLoadingEvent.accept(.failure(LoginError.timeOut))
            })
            .subscribe(with: self, onNext: { vm, value in
                vm.steps.accept(CodestackStep.userLoggedIn(nil, nil))
                vm.loginLoadingEvent.accept(.success(false))
            }).disposed(by: disposeBag)
    }
    
    func requestFirebaseAnonymousAuth() {
        authUsecase
            .firebaseAnonymousAuth()
            .do(onError: { [weak self] _ in
                self?.loginLoadingEvent.accept(.failure(LoginError.timeOut))
            })
            .subscribe(with: self, onNext: { vm, value in
                vm.steps.accept(CodestackStep.userLoggedIn(nil, nil))
                vm.loginLoadingEvent.accept(.success(false))
            }).disposed(by: disposeBag)
    }

    
    func oAuthComplte(apple code: String, user: String) {
        _ = authUsecase
            .request(apple: code , user: user )
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
            .do(onNext: { [weak self] _ in self?.loginLoadingEvent.accept(.success(false)) })
            .do(onError: { [weak self] _ in self?.loginLoadingEvent.accept(.failure(LoginError.timeOut)) })
            .flatMap { token in self.saveToken(token: token) }
            .subscribe(with: self, onNext: { owner, user in owner.saveUserInfo(member: user) },
                       onError: { owner , err in /*Log.error(err)*/ })
    }
    
    /// gitHub OAuh 가 끝나고 다시 서버로 token 요청하는 함수
    /// - Parameter code: github code
    func oAuthComplete(code: GitCode){
        _ = authUsecase
            .request(with: code)
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
            .do(onNext: { [weak self] _ in self?.loginLoadingEvent.accept(.success(false))})
            .do(onError: { [weak self] err in self?.loginLoadingEvent.accept(.failure(LoginError.timeOut)) })
            .flatMap { token in self.saveToken(token: token) }
            .subscribe(with: self,onNext: { owner, user in owner.saveUserInfo(member: user)},
                                    onError: { owner , err in /*Log.error(err)*/ })
    }
    
    private func requestAuth(id: String, pwd: String){
        _ = authUsecase
            .requestLogin(name: id, password: pwd)
            .do(onNext: { [weak self] _ in self?.loginLoadingEvent.accept(.success(false))})
            .do(onError: { [weak self] _ in self?.loginLoadingEvent.accept(.failure(LoginError.timeOut)) })
            .map { _ in CodestackStep.userLoggedIn(nil, nil)}
            .subscribe(with: self, onNext: { vm, stpes in
                vm.steps.accept(stpes)
            }, onError: { vm, err in
//                Log.debug("err: \(err)")
            })
            .disposed(by: disposeBag)
    }
    
    
    private func saveToken(token: CSTokenVO) -> Observable<MemberVO> {
        authUsecase.saveToken(token: token)
        return authUsecase.fetchMe()
    }
    
    private func saveUserInfo(member: MemberVO){
        // TODO: 바꿔야됌
        authUsecase.saveMember(member: member)
        steps.accept(CodestackStep.userLoggedIn(nil, nil))
    }
}
