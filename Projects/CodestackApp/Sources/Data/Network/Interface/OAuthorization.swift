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
