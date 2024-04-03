//
//  JudgeSubmissionDTO.swift
//  CSNetwork
//
//  Created by 박형환 on 4/22/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation


public struct JudgeSubmissionResponseDTO: Codable {
    public var token:          String?
    public var stdout:         String?
    public var time:           String?
    public var memory:         Double?
    public var stderr:         String?
    public var compile_output: String?
    public var message:        String?
    public var status:         JudgeZeroStatusDTO?
}


public struct JZSubmissionTokenResponse: Codable {
    public let token: String
}

public struct JudgeZeroSubmissionRequestDTO: Codable {
    
    public let sourceCode: String
    
    public let languageID: Int
    
    // 프로그램에 대한 입력입니다. 입력이 필요하지 않을 경우 null로 설정됩니다.
    public var stdin: String?
    
    // 프로그램의 예상 출력입니다. stdout과 비교할 때 사용됩니다. 프로그램의 출력이 예상 출력과 일치하는지 확인하는 데 사용됩니다.
    public var expected_output: String?
    
    // (실행 시간 제한): 프로그램의 전체 실행 시간 제한입니다. CPU 시간 제한과 달리 프로그램의 시작부터 종료까지 측정합니다.
    public var wall_time_limit: Double?
    
    public init(sourceCode: String, 
         languageID: Int,
         stdin: String? = nil,
         expected_output: String? = nil, 
         wall_time_limit: Double? = nil)
    {
        self.sourceCode = sourceCode
        self.languageID = languageID
        self.stdin = stdin
        self.expected_output = expected_output
        self.wall_time_limit = wall_time_limit
    }
    
    enum CodingKeys: String, CodingKey {
        case sourceCode = "source_code"
        case languageID = "language_id"
        case stdin
        case expected_output
        case wall_time_limit
    }
    
    func toBase64(_ str: String?) -> String {
        str?.data(using: .utf8)?.base64EncodedString() ?? ""
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(toBase64(self.sourceCode), forKey: .sourceCode)
        try container.encode(self.languageID, forKey: .languageID)
        try container.encodeIfPresent(toBase64(self.stdin), forKey: .stdin)
        try container.encodeIfPresent(toBase64(self.expected_output), forKey: .expected_output)
        try container.encodeIfPresent(self.wall_time_limit, forKey: .wall_time_limit)
    }
}


public struct JudgeZeroStatusDTO: Codable {
    public let id: Int              // 1 ~ 14
    public let description: String
    
    public init(id: Int, description: String) {
        self.id = id
        self.description = description
    }
}
