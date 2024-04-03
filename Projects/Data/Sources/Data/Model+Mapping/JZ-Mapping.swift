//
//  JZ-mapping.swift
//  Data
//
//  Created by 박형환 on 4/22/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import CSNetwork
import Domain
import Global

extension JudgeZeroStatusDTO {
    func toDomain() -> JudgeZeroStatus {
        .init(id: self.id, description: self.description)
    }
}
extension JudgeSubmissionResponseDTO {
    func toDomain() -> JudgeZeroSubmissionVO {
        .init(id: self.token ?? "",
              stdout: self.stdout ?? "",
              stderr: self.stderr ?? "",
              compile_output: self.compile_output ?? "",
              time: self.time ?? "",
              memory: self.memory ?? 0,
              status: self.status?.toDomain() ?? .init(id: 13, description: ""),
              finished_at: Date().toString())
    }
}
