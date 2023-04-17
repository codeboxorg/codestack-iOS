//
//  CellIdentifierProtocol.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/16.
//

import Foundation

protocol CellIdentifierProtocol{
    static var identifier: String { get }
}
extension CellIdentifierProtocol{
    static var identifier: String{
        String(describing: Self.self)
    }
}

extension ProblemCell: CellIdentifierProtocol{}
