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
import Global
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
//        let loginService: Auth
//        let apolloService: WebRepository
        let authUsecase: AuthUsecase
        let stepper: LoginStepper
    }
    
//    private var loginService: Auth
//    private var apolloService: WebRepository
    private var disposeBag = DisposeBag()
    private let authUsecase: AuthUsecase
    init(dependency: Dependency){
//        self.loginService = dependency.loginService
//        self.apolloService = dependency.apolloService
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
                        Log.error("github 로그인 실패 : \(error)")
                    }
                case .email((let id, let pwd)):
//                    vm.loginLoadingEvent.accept(.success(true))
//                    vm.steps.accept(CodestackStep.userLoggedIn(nil, nil))
//                    vm.loginLoadingEvent.accept(.success(false))
                    #if DEBUG
                    // TODO: 502 Bad Gate Way
                     vm.requestAuth(id: id, pwd: pwd)
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

    
    func oAuthComplte(apple code: String, user: String) {
        //        _ = loginService
        //            .request(with: token)
        _ = authUsecase
            .request(apple: code , user: user )
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
            .do(onNext: { [weak self] _ in self?.loginLoadingEvent.accept(.success(false)) })
            .do(onError: { [weak self] _ in self?.loginLoadingEvent.accept(.failure(LoginError.timeOut)) })
            .flatMap { token in self.saveToken(token: token) }
            .subscribe(with: self, onNext: { owner, user in owner.saveUserInfo(memeber: user) },
                       onError: { owner , err in Log.error(err) })
    }
    
    /// gitHub OAuh 가 끝나고 다시 서버로 token 요청하는 함수
    /// - Parameter code: github code
    func oAuthComplete(code: GitCode){
//        _ = loginService
//            .request(with: code)
        _ = authUsecase
            .request(with: code)
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
            .do(onNext: { [weak self] _ in self?.loginLoadingEvent.accept(.success(false))})
            .do(onError: { [weak self] err in self?.loginLoadingEvent.accept(.failure(LoginError.timeOut)) })
            .flatMap { token in self.saveToken(token: token) }
            .subscribe(with: self,onNext: { owner, user in owner.saveUserInfo(memeber: user)},
                                    onError: { owner , err in Log.error(err) })
    }
    
    private func requestAuth(id: String, pwd: String){
//        _ = loginService.request(name: id, password: pwd)
        _ = authUsecase
            .request(name: id, password: pwd)
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
            .do(onNext: { [weak self] _ in self?.loginLoadingEvent.accept(.success(false)) })
            .do(onError: { [weak self] _ in self?.loginLoadingEvent.accept(.failure(LoginError.timeOut)) })
            .flatMap { token in
                // FIXME: KeyChain 계층 변경ㅇ해야됌
//                Log.debug(KeychainItem.currentAccessToken)
                return self.saveToken(token: token) }
            .subscribe(with: self,onNext: { owner, user in owner.saveUserInfo(memeber: user) },
                                    onError: { owner , err in Log.error(err) })
    }
    
    
    private func saveToken(token: CSTokenVO) -> Observable<MemberVO> {
        // TODO: 바꿔야됌
//        UserManager.shared.saveTokenInfo(with: TokenInfo(expiresIn: token.expiresIn,
//                                                         tokenType: token.tokenType))
//        
//        KeychainItem.saveTokens(access: token.accessToken, refresh: token.refreshToken)
//        
        return authUsecase.fetchMe()
//            .map { fr in fr.toDomain() }
    }
    
    private func saveUserInfo(memeber: MemberVO){
        // TODO: 바꿔야됌
        //UserManager.shared.saveUser(with: memeber)
        steps.accept(CodestackStep.userLoggedIn(nil, nil))
    }
}
