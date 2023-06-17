//
//  CodestackStep.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/07.
//

import Foundation
import RxFlow



enum ButtonType{
    case today_problem(CodestackStep?)
    case recommand_problem(CodestackStep?)
    case none
}


enum CodestackStep: Step, CaseIterable{
    static var allCases: [CodestackStep] = []
    
    // Global
    case logoutIsRequired
    case dashboardIsRequired
    case alert(String)
    case fakeStep
    case unauthorized
    
    // Login
    case loginNeeded
    case userLoggedIn(ID?,Pwd?)
    
    
    //Home Step
    case firstHomeStep
    
    //problemSolve VC
    case problemComplete
    case problemList
    case problemPick(String)
    
    case sideMenuDelegate(String)
    
    case none
    
}
