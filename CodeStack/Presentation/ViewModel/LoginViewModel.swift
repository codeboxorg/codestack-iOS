//
//  LoginViewModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/30.
//

import Foundation


protocol LoginViewModelProtocol: AnyObject{
    func requestOAuth() throws
}

enum LoginError: Error{
    case gitOAuthError
}

class LoginViewModel: LoginViewModelProtocol{
    
    private weak var service: OAuthrizationRequest?
    
    init(service: OAuthrizationRequest){
        self.service = service
        
        
    }
    
    func requestOAuth() throws {
        do {
            try service?.gitOAuthrization()
        }catch{
            throw LoginError.gitOAuthError
        }
    }
    
    
}
