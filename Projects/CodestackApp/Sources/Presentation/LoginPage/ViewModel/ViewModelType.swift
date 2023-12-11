//
//  ViewModelType.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/08.
//

import Foundation

protocol ViewModelType{
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
