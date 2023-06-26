//
//  Member.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
//

import Foundation


struct Member: Codable{
    let username: String?
    let nickname: String?
    let email: String?
    let profileImage: String?
    let problemCalendar: [ProblemCalendar?]
    
    //MARK: 나중에 데이터 타입 확인 필요
    let year: String?
}


