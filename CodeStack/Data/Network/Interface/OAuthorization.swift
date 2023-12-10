//
//  NetworkInterface.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/03.
//

import Foundation
import RxSwift

typealias OAuthrizationRequest = GitOAuthorization & AppleAuthorization & CodestackAuthorization

protocol OAuthorization { }


protocol TestService{
    func request() -> SubmissionPagedResult
    func request(type: SegType.Value) -> SubmissionPagedResult
}


//MARK: TestMock 삭제예졍

class NetworkService: TestService{
    
    func request() -> SubmissionPagedResult {
        let sub = Submission.dummy()
//        let result = SubmissionPagedResult(content: sub, pageInfo: _PageInfo(totalElement: 1, totalPage: 1))
        return SubmissionPagedResult(content: [], pageInfo: .init(totalElement: 0, totalPage: 0))
    }
    
    func request(type: SegType.Value) -> SubmissionPagedResult {
        let sub = Submission.dummy(type: type)
        let result = SubmissionPagedResult(content: sub, pageInfo: _PageInfo(totalElement: 1, totalPage: 1))
        return result
    }
}
