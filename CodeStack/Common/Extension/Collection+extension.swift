//
//  Collection+extension.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/14.
//

import Foundation



//MARK: - Collection 에 접근할때 범위 체크 -> 안전배열
extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
extension Array {
    subscript(safe range: Range<Index>) -> ArraySlice<Element>? {
        
        if range.endIndex > endIndex {
            if range.startIndex >= endIndex {return nil}
            else {return self[range.startIndex..<endIndex]}
        }
        else {
            return self[range]
        }
    }
}
////MARK: - Array 에 접근할때 범위 체크 -> 안전배열
//extension Array {
//    subscript(safe index: Index) -> Element? {
//        return indices.contains(index) ? self[index] : nil
//    }
//}

