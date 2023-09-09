//
//  MemberDTO.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/08.
//

import Foundation

//MARK: REST API , 회원가입 모델로 사용
struct MemberDTO: Codable {
    let id: ID
    let password: Pwd
    let email: String
    let nickName: String
    var imageURL: String?
}
