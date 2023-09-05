//
//  GitHubLoginManager.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/30.
//

import UIKit
import RxSwift
import RxCocoa

final class LoginService: NSObject{
    
    let urlSession: URLSession
    
    var loginViewModel: (any LoginViewModelProtocol)?
    
    var disposeBag = DisposeBag()
    
    init(_ session: URLSession = URLSession(configuration: .default)) {
        self.urlSession = session
        super.init()
    }
}
