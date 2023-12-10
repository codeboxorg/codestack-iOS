//
//  CSError.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/30.
//

import Foundation

//custom error
enum APIError: Error{
    case badURLError
    case badURLRequest
    case canNotOpen
    case JSONSerializationDataError
    case fetchError
    case decodingError
    case encodingError
    case emptyDataError
    case httpResponseError(code: Int)
    case unKnown
    
    
    var info: String {
        switch self {
        case .badURLError:                      return "유효하지 않은 URL입니다."
        case .badURLRequest:                    return "유효하지 않은 Request입니다."
        case .canNotOpen:                       return "열수가 없는 URL 입니다."
        case .JSONSerializationDataError:       return "JSON Serialization 중 에러가 발생했습니다."
        case .fetchError:                       return "fetch를 할수 없습니다."
        case .decodingError:                    return "Decoding 중 에러가 발생했습니다."
        case .encodingError:                    return "Encoding 중 에러가 발생했습니다."
        case .emptyDataError:                   return "데이터가 비어있습니다."
        case .httpResponseError(let code):      return "HTTP ResponseError error 코드는 \(code) 입니다."
        case .unKnown:                          return "알수 없는 에러 발생"
        }
    }
}
