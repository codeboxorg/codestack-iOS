//
//  CSError.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/30.
//

import Foundation

//custom error
enum CSError: Error{
    case badURLError
    case badURLRequest
    case canNotOpen
    case JSONSerializationDataError
    case fetchError
    case decodingError
    case encodingError
    case emptyDataError
    case responseError
    case httpResponseError(code: Int)
    case unKnown
}
