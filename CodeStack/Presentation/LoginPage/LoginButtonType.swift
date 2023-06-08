//
//  LoginButtonType.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/08.
//

import Foundation

typealias ID = String
typealias Pwd = String

enum LoginButtonType{
    case gitHub
    case apple
    case email((ID,Pwd))
    case none
}
