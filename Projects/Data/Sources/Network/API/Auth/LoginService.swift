//
//  GitHubLoginManager.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/30.
//

import UIKit
import RxSwift
import RxCocoa

public protocol LoginViewModelProtocol: AnyObject {
    func requestOAuth() throws
    
    /// Git Auth Complte
    /// - Parameter code: git Authorize code
    func oAuthComplete(code: String)
    
    func oAuthComplte(apple token: AppleDTO)
}


public final class LoginService: NSObject {
    
    let urlSession: URLSession
    
    public weak var loginViewModel: (any LoginViewModelProtocol)?
    
    var disposeBag = DisposeBag()
    
    
    public init(_ session: URLSession = URLSession(configuration: .default)) {
        self.urlSession = session
        super.init()
    }
}
