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


enum CodestackStep: Step, CaseIterable, Equatable{
    static var allCases: [CodestackStep] = []
    
    //onBoarding
    case onBoardingRequired
    case onBoardingComplte
    
    
    // Global
    case logoutIsRequired
    case dashboardIsRequired
    case alert(String)
    case fakeStep
    case unauthorized
    
    // Login
    case loginNeeded
    case userLoggedIn(ID?,Pwd?)
    
    case logout
    
    
    //myPage
    case profilePage
    
    //Home Step
    case firstHomeStep
    
    //problemSolve VC
    case problemComplete
    case problemList
    case problemPick(String)
    case recentSolveList
    case recommendPage
    
    case sideMenuDelegate(String)
    case sideShow
    case sideDissmiss
    
    
    case historyflow
    
    case none
    
}
