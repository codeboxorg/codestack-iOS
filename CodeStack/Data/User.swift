//
//  Member.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
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

struct User: Codable{
    let username: String?
    let nickname: String?
    let email: String?
    let profileImage: String?
    let problemCalendar: [ProblemCalendar?]
    
    //MARK: 나중에 데이터 타입 확인 필요
    let year: String?
    
    init() {
        self.username = nil
        self.nickname = nil
        self.email = nil
        self.profileImage = nil
        self.problemCalendar = []
        self.year = nil
    }
}

//MARK: GraphQL response maaping initializer
extension User{
    init(with member: SubmissionMutation.Member){
        self.nickname = member.nickname
        self.problemCalendar = []
        self.email = nil
        self.profileImage = nil
        self.username = nil
        self.year = nil
    }
    
    init(me member: Member) {
        
        self.nickname = member.nickname
        self.problemCalendar = []
        self.email = member.email
        self.profileImage = member.profileImage
        self.username = member.username
        self.year = nil
    }
}



