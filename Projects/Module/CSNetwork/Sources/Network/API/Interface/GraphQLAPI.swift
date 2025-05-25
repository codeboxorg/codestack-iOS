//
//  Interface.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/25.
//

import Foundation
//import CodestackAPI
//import Apollo
import RxSwift

public protocol GraphQLAPI {
    func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy,
        queue: DispatchQueue) -> Maybe<Query.Data>

    func perform<Query: GraphQLMutation>(
        query: Query,
        cachePolichy: CachePolicy ,
        queue: DispatchQueue) -> Maybe<Query.Data>
}
