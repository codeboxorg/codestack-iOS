//
//  HTTPHeaderFiled.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/30.
//

import Foundation

enum HTTPHeaderFields {
    case application_json
    case multipart_form_data
    case encoded
    case none
    
    var string: String {
        switch self{
        case .application_json:
            return "application/json"
        case .multipart_form_data:
            return "multipart/form"
        case .encoded:
            return "application/x-www-form-urlencoded"
        case .none:
            return "none"
        }
    }
}



