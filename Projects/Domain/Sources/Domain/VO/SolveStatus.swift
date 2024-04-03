//
//  SolveStatus.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/16.
//

import UIKit

public enum SolveStatus: String, CaseIterable, Equatable, Codable {
    
    public static var allCases: [SolveStatus] = [.temp,.favorite, .AC,.WA, .PE, .RE, .TLE, .MLE,.OLE]
    
    case temp
    case favorite
    case PROCEESING // 진행중
    case AC       // ✅정답
    case WA       // ❗️오답
    case PE       // ❗️출력 형식 다름
    case RE       // ⚠️ 준비중
    case TLE      // ❗️시간 초과
    case MLE      // ❗️메모리 초과
    case OLE      // ⚠️ 값 출력 초과
    case SIGSEGV  // ❗️잘못된 메모리 주소 접근
    case SIGXFSZ  // ❗️파일 크기 제한 초과
    case SIGFPE   // ❗️부동 소수점 연산 오류
    case SIGABRT  // ❗️프로그램이 자체적으로 종료
    case NZEC     // ❗️비정상적인 종료 코드
    case Other    // ❗️기타 런타임 오류
    case none     // ❗️상태 없음 (N/A)
    
    
    public var tag: String {
        switch self {
        case .PROCEESING:
            return "진행중"
        case .temp:
            return "임시"
        case .favorite:
            return "즐겨찾기"
        case .AC:
            return "정답"
        case .WA:
            return "오답"
        case .PE:
            return "출력형식 다름"
        case .RE:
            return "준비"
        case .TLE:
            return "시간 초과"
        case .MLE:
            return "메모리 초과"
        case .OLE:
            return "출력 초과"
        case .SIGSEGV:
            return "메모리 접근"
        case .SIGXFSZ:
            return "파일크기 초과"
        case .SIGFPE:
            return "SIGFPE"
        case .SIGABRT:
            return "SIGABRT"
        case .NZEC:
            return ".NZEC"
        case .Other:
            return "알수없는 에러"
        case .none:
            return "N/A"
        }
    }
    
    public var value: String {
        switch self {
        case .temp:
            return "임시"
        case .favorite:
            return "좌요"
        case .PROCEESING:
            return "진행중"
        case .AC:
            return "정답"
        case .WA:
            return "오답"
        case .PE:
            return "출력 형식 다름"
        case .RE:
            return "준비"
        case .TLE:
            return "시간 초과"
        case .MLE:
            return "메모리 초과"
        case .OLE:
            return "출력 초과"
        case .SIGSEGV:
            return "메모리"
        case .SIGXFSZ:
            return "크기제한"
        case .SIGFPE:
            return "부동소수점 오류"
        case .SIGABRT, .NZEC:
            return "비정상적 종료"
        case .Other:
            return "알수없는 에러"
        case .none:
            return "N/A"
        }
    }
}
