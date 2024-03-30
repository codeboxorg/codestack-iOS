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

extension FBDocuments where T == ProblemDTO {
    func toDomain() -> [ProblemVO] {
        self.store.map { $0.toDomain() }.sorted(by: { Int($0.id)! < Int($1.id)! })
    }
}

extension ProblemDTO {
    
    func toDomain() -> ProblemVO {
        .init(id: self.id,
              title: self.title,
              context: self.contextID,
              languages: self.languages.compactMap { LanguageVO.languageMap[$0] },
              tags: self.tags.map { TagVO(id: "", name: $0) },
              accepted: Double(self.accepted) ?? 0,
              submission: Double(self.submission) ?? 0,
              maxCpuTime: self.maxCpuTime,
              maxMemory: Double(self.maxMemory) ?? 0)
    }
}

extension Post {
    func toDomain() -> PostVO {
        .init(markdown: markdown)
    }
}

extension Store {
    func toDomain() -> StoreVO {
        .init(userId: userId,
              title: title,
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
              preferLanguage: self.preferLanguage,
              profileImagePath: self.profileURL) // TODO: imageURL ㅊ구ㅏ
    }
}
