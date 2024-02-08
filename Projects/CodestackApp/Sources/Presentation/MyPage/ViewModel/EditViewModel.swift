//
//  EditViewModel.swift
//  CodestackApp
//
//  Created by 박형환 on 1/15/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import Domain

struct EditViewModel {
    let imageURL: String
    let image: Data
    let email: String
    let nickName: String
}

extension EditViewModel: Equatable {
    static var sample: Self {
        .init(imageURL: "codestack",
              image: Data(),
              email: "N/A",
              nickName: "N/A")
    }
    
    func toDomain() -> MemberVO {
        MemberVO(email: self.email,
                 nickName: self.nickName,
                 username: "",
                 solvedProblems: [],
                 profileImage: self.imageURL)
    }
}
extension MemberVO {
    func toVM(_ data: Data) -> EditViewModel {
        .init(imageURL: self.profileImage,
              image: data,
              email: self.email,
              nickName: self.nickName)
    }
}
