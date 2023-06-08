//
//  CodestackStep.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/07.
//

import Foundation
import RxFlow

enum CodestackStep: Step{
    // Global
    case logoutIsRequired
    case dashboardIsRequired
    case alert(String)
    case fakeStep
    case unauthorized
    
    // Login
    case loginNeeded
    case userLoggedIn(ID?,Pwd?)
    
    //problemSolve VC
    case problemList
    case problemPick(String)
    
    case sideMenuDelegate(String)
    
}
