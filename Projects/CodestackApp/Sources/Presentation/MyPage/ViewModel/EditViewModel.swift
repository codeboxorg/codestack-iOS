//
//  EditViewModel.swift
//  CodestackApp
//
//  Created by 박형환 on 1/15/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import Domain

enum UpdateState {
    case imageState(Data,nickname: String)
    case email(String)
    case nickname(String)
}

struct EditViewModel {
    let imageURL: String
    var image: Data
    var email: String
    var nickName: String
}

extension EditViewModel: Equatable {
    
    func isEqual(to vm: Self) -> [UpdateState] {
        var state: [UpdateState] = []
        if email != vm.email { state.append(.email(vm.email)) }
        if nickName != vm.nickName { state.append(.nickname(vm.nickName)) }
        if image != vm.image { state.append(.imageState(vm.image, nickname: nickName)) }
        return state
    }
    
    
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
