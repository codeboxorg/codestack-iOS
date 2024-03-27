//
//  SolveStatusStyle.swift
//  CommonUI
//
//  Created by 박형환 on 2/26/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit
import Domain

extension SolveStatus {
    var color: UIColor {
        switch self {
        case .temp:
            return .lightGray
            
        case .favorite:
            return .sky_blue
            
        case .PE,.RE,.OLE, .PROCEESING:
            return .systemYellow
            
        case .AC:
            return .green
            
        case .WA,.TLE,.MLE, .NZEC ,
            .SIGABRT, .SIGFPE, .SIGSEGV,
            .SIGXFSZ, .Other:
            return .red
            
        case .none:
            return .black
        }
    }
    
    func checkIsEqual(with segType: SegType.Value) -> Bool{
        switch segType {
        case .favorite:
            return self == SolveStatus.favorite ? true : false
        case .tempSave:
            return self == SolveStatus.temp ? true : false
        case .all:
            return true
        case .none:
            return false
        }
    }
}
