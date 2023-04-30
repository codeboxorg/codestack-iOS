//
//  AppleOAuthrizationRequest.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/30.
//

import Foundation
import AuthenticationServices


protocol AppleOAuthrizationRequest{
    
}
extension AppleOAuthrizationRequest{
    
}


class AppleLoginManager:NSObject,ASAuthorizationControllerDelegate{
    
    weak var loginViewcontroller: LoginViewController?
    var currentNonce: String?
    
    override init(){
        super.init()
    }
    
    convenience init(_ dependency: LoginViewController){
        self.init()
        self.loginViewcontroller = dependency
    }
    
    func settingLoginView(){
        self.setupProviderLoginView()
    }
    
}
extension AppleLoginManager: ASAuthorizationControllerPresentationContextProviding{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.loginViewcontroller!.view.window!
    }
    
    
}

extension AppleLoginManager: AppleOAuthrizationRequest{
    
    /// - Tag: add_appleid_button
    /// - 애플 로그인 버튼을 추가한다.
    /// ASAuthorizationAppleIDButton -> apple login Button
    /// addTarget event register
    private func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.cornerRadius = 12
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.loginViewcontroller?.loginView.loginProviderStackView.addArrangedSubview(authorizationButton)
    }
    
    /// - Tag: perform_appleid_request
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        
        let nonce = String.randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        
        request.requestedScopes = [.fullName, .email]
        request.nonce = nonce.sha256()
        
        // ASAuthorizationController -> A controller that manages authorization requests created by a provider.
        // 프로바이더로 생성된 요청을 관리 하는 컨트롤러 이다.
        // 이 컨트롤러의 delegate 와 presentationContextProvider 를 VC에 위임한다.
        // performRequests ->
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        //@abstract This delegate will be invoked upon completion of the authorization indicating success or failure.
        // Delegate is required to receive the results of authorization.
        // 이 delegate는 인증 의 성공, 실패 여부를 나타내기 위한 completion 완료 여부를 삽입할 것이다.
        // 인증의 결과를 받기 위해서 필요하다.
        authorizationController.delegate = self
        
        // @abstract This delegate will be invoked upon needing a presentation context to display authorization UI.
        // 이 delegate는 인증 UI를 화면에 보여주기 위해서 필요한 delegate이다.
        authorizationController.presentationContextProvider = self
        
        authorizationController.performRequests()
    }
}
