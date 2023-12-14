//
//  AuthProvider.swift
//  Data
//
//  Created by 박형환 on 12/14/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation

public enum OAuthProvider {
    case github(GitCode)
    case apple(AppleDTO)
    case email(CSDTO)
    
    var value: String {
        switch self {
        case .github:
            return "github"
        case .apple:
            return "apple"
        case .email:
            return "email"
        }
    }
    
    func makeBody() -> [String : String] {
        switch self {
        case .github(let gitCode):
            return ["code" : gitCode]
        case .apple(let appleToken):
            if let _ = appleToken.user {
                return [ "code" : appleToken.authorizationCode]
            }else{
                return [ "code" : appleToken.authorizationCode]
            }
        case .email(let idpwd):
            return ["email" : idpwd.id,
                    "password" : idpwd.password]
        }
    }
}
