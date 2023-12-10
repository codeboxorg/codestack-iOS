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
////MARK: - Array 에 접근할때 범위 체크 -> 안전배열
//extension Array {
//    subscript(safe index: Index) -> Element? {
//        return indices.contains(index) ? self[index] : nil
//    }
//}

