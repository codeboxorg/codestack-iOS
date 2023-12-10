//
//  Dictionary.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/21.
//

import Foundation



extension Dictionary where Key == String {
    
    func sortDictionaryKeysByDate() -> [Value] {
        // Dictionary의 key를 Date로 변환하여 정렬
        
        return self.keys.sorted().map { self[$0]! }
    }

}
