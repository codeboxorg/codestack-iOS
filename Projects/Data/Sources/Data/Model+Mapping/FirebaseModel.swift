//
//  FirebaseModel.swift
//  Data
//
//  Created by 박형환 on 1/26/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import CSNetwork
import Domain

extension FBDocuments where T == Store {
    func toDomain() -> DocumentVO {
        .init(store: self.store.map { $0.toDomain() })
    }
}

extension Post {
    func toDomain() -> PostVO {
        .init(markdown: markdown)
    }
}

extension Store {
    func toDomain() -> StoreVO {
        .init(title: title,
              name: name,
              date: date,
              description: description,
              markdown: markdownID,
              tags: tags)
    }
}

extension FBUserDTO {
    func toDomain() -> FBUserNicknameVO {
        .init(nickname: self.nickname,
              preferLanguage: self.preferLanguage) // TODO: imageURL ㅊ구ㅏ
    }
}
