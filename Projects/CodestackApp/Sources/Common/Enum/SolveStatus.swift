//
//  SolveStatus.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/16.
//

import UIKit

enum ProblemStatus {
    case temp
    case favorite
    case solve(SolvedStatus)
    case fail(FailStatus)
}

enum SolvedStatus {
    case AC   // 정답 green
}

enum FailStatus {
    case WA   // 오답 red
    case PE   // 출력 형식 다름 yellow
    case RE   // 준비중 yellow
    case TLE  // 시간 초과 red
    case MLE  // 메모리 초과 red
    case OLE  // 값 출력 초과 yello
    case none
}

enum SolveStatus: String, CaseIterable{
    
    static var allCases: [SolveStatus] = [.temp,.fail,.favorite,.solve]
    
    case temp
    case favorite
    case solve
    case fail
    
    case AC   // 정답 green
    case WA   // 오답 red
    case PE   // 출력 형식 다름 yellow
    case RE   // 준비중 yellow
    case TLE  // 시간 초과 red
    case MLE  // 메모리 초과 red
    case OLE  // 값 출력 초과 yello
    case none
    
    
    var tag: String {
        switch self {
        case .temp:
            return "임시"
        case .favorite:
            return "즐겨찾기"
        case .solve:
            return "성공"
        case .fail:
            return "실패"
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
        case .none:
            return "N/A"
        }
    }
    
    var value: String {
        switch self {
        case .temp:
            return "임시"
        case .favorite:
            return "좌요"
        case .solve:
            return "성공"
        case .fail:
            return "실패"
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
        case .none:
            return "N/A"
        }
    }
    
    var color: UIColor {
        switch self {
        case .temp:
            return .lightGray
            
        case .favorite:
            return .sky_blue
            
        case .PE,.RE,.OLE:
            return .systemYellow
            
        case .solve,.AC:
            return .green
            
        case .fail,.WA,.TLE,.MLE:
            return .red
            
        case .none:
            return .black
        }
    }
}

extension String {
    func convertSolveStatus() -> SolveStatus {
        switch self{
        case "fail":
            return .fail
        case "success":
            return .solve
        case "temp":
            return .temp
        case "favorite":
            return .favorite
        case "Ready","RE":
            return .RE
        case "AC":
            return .AC
        case "WA":
            return .WA
        case "PE":
            return .PE
        case "TLE":
            return .TLE
        case "MLE":
            return .MLE
        case "OLE":
            return .OLE
        default:
            return .none
        }
    }
    
    func checkIsEqual(with segType: SegType.Value) -> Bool{
        switch segType {
        case .favorite:
            return self == SolveStatus.favorite.rawValue ? true : false
        case .tempSave:
            return self == SolveStatus.temp.rawValue ? true : false
        // case .success:
        //     return self == SolveStatus.AC.rawValue ? true : false
        // case .failure:
        //     return self.isFailure()
        case .all:
            return true
        case .none:
            return false
        }
    }
    
    func isFailure() -> Bool{
        if  self == SolveStatus.WA.rawValue ||
                self == SolveStatus.MLE.rawValue ||
                self == SolveStatus.TLE.rawValue ||
                self == SolveStatus.RE.rawValue ||
                self == "Ready" ||
                self == SolveStatus.OLE.rawValue {
            return true
        }else{
            return false
        }
    }
    
}
