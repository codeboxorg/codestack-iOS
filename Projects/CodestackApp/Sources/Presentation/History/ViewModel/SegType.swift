//
//  SegType.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/20.
//

import Foundation
import Domain


enum SegType: String, CaseIterable {
    static var allSegTypes: [String] = [favorite.rawValue, tempSave.rawValue, all.rawValue ]
    
    case favorite = "즐겨찾기"
    case tempSave = "임시"
    case all = "전체"
    
    enum Value: Int{
        case favorite = 0
        case tempSave = 1
        case all = 2
        case none = 3
        
        func isAll() -> Bool{
            return self.rawValue == 2
        }
    }
    
    static func switchSegType(value: Value) -> SolveStatus {
        switch value{
        case .favorite:
            return .favorite
        case .tempSave:
            return .temp
        default:
            return .none
        }
    }
}
