//
//  API-REST.swift
//  Data
//
//  Created by 박형환 on 1/9/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

//MARK: Function
extension API {
    public func REST_ENDPOINT(path: API) -> String {
        switch path {
        case .rest(let restAPI):
            switch restAPI {
            case .reissue:
                return base + "v1/auth/token"
            case .regitster:
                return base + "v1/auth/register"
            case .password:
                return base + "v1/auth/password"
            case .profile:
                return base + "v1/member/profile"
            case .health:
                return base + "health"
            case .auth(let provider):
                return authEndpoint(provider: provider)
            default:
                fatalError("value")
            }
        default:
            fatalError("not found")
        }
    }
    
    private func authEndpoint(provider: OAuthProvider) -> String{
        switch provider {
        case .email:
            return base + "v1/auth/login"
        default:
            return base + "v1/oauth2/login/" + "\(provider.value)"
        }
    }
}
