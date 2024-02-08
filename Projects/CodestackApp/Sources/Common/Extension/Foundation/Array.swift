//
//  Array.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/13.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            return Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
    
    func element(at index: Int) -> Element? {
        index >= 0 && index < endIndex ? self[index] : nil
    }
    
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
