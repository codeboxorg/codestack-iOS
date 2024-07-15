//
//  JudgeStatus.swift
//  Domain
//
//  Created by 박형환 on 4/22/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

public struct JudgeZeroStatus: Codable {
    public let id: Int              // 1 ~ 14
    public let description: String
    
    public init(id: Int, description: String) {
        self.id = id
        self.description = description
    }
}

public extension JudgeZeroStatus {
    
    func isProcessing() -> Error? {
        #if Dev
        print("error: \(self.id), description: \(self.description)")
        #endif
        if self.id == 1 || self.id == 2 { return JZError.isProcessing }
        return nil
    }
    
    func mapJSONToSolveStatus() -> SolveStatus {
        switch self.id {
        case 1:
            return .RE
        case 2:
            return .RE
        case 3:
            return .AC
        case 4:
            return .WA
        case 5:
            return .TLE
        case 6:
            return .PE
        case 7:
            return .SIGSEGV // Runtime Error (SIGSEGV)
        case 8:
            return .SIGXFSZ // Runtime Error (SIGXFSZ)
        case 9:
            return .SIGFPE // Runtime Error (SIGFPE)
        case 10:
            return .SIGABRT // Runtime Error (SIGABRT)
        case 11:
            return .NZEC // Runtime Error (NZEC)
        case 12:
            return .Other // Runtime Error (Other)
        case 13:
            return .none // Internal Error
        case 14:
            return .RE // Exec Format Error
        default:
            return .none
        }
    }
}

//[
//  {
//    "id": 1,
//    "description": "In Queue"
//  },
//  {
//    "id": 2,
//    "description": "Processing"
//  },
//  {
//    "id": 3,
//    "description": "Accepted"
//  },
//  {
//    "id": 4,
//    "description": "Wrong Answer"
//  },
//  {
//    "id": 5,
//    "description": "Time Limit Exceeded"
//  },
//  {
//    "id": 6,
//    "description": "Compilation Error"
//  },
//  {
//    "id": 7,
//    "description": "Runtime Error (SIGSEGV)"
//  },
//  {
//    "id": 8,
//    "description": "Runtime Error (SIGXFSZ)"
//  },
//  {
//    "id": 9,
//    "description": "Runtime Error (SIGFPE)"
//  },
//  {
//    "id": 10,
//    "description": "Runtime Error (SIGABRT)"
//  },
//  {
//    "id": 11,
//    "description": "Runtime Error (NZEC)"
//  },
//  {
//    "id": 12,
//    "description": "Runtime Error (Other)"
//  },
//  {
//    "id": 13,
//    "description": "Internal Error"
//  },
//  {
//    "id": 14,
//    "description": "Exec Format Error"
//  }
//]
