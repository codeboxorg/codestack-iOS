//
//  SolveStatus.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/16.
//

import Foundation


enum SolveStatus: CaseIterable{
    
    static var allCases: [SolveStatus] = [.temp,.fail,.favorite,.solve]
    
    case temp
    case favorite
    case solve
    case fail
    case none
}
