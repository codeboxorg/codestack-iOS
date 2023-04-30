//
//  GitHubLoginManager.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/30.
//

import Foundation
import RxSwift
import RxCocoa

final class ServiceManager: NSObject{
    
    let urlSession: URLSession
    
    var disposeBag = DisposeBag()
    
    init(_ session: URLSession = URLSession(configuration: .default)) {
        self.urlSession = session
        
        super.init()
        
    }
}

extension ServiceManager: GitOAuthrizationRequest{
    func gitOAuthrization() throws{
        guard let url = makeGitURL() else { throw CSError.badURLError}
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }else{
            throw CSError.canNotOpen
        }
    }
    
    func request(code: String) -> Maybe<GitToken>{
        
        guard let request = try? self.postGitRequest(code: code) else {return Maybe.error(CSError.badURLRequest)}
        return URLSession.shared.rx
            .response(request: request)
            .asMaybe()
            .map{ (response: HTTPURLResponse, data: Data) -> GitToken in
                if  (200..<300) ~= response.statusCode {
                    do{
                        let token = try JSONDecoder().decode(GitToken.self, from: data)
                        return token
                    }catch{
                        throw CSError.decodingError
                    }
                }else {
                    print(response)
                    throw CSError.httpResponseError(code: response.statusCode)
                }
            }
    }
}
