//
//  CodestackStep.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/07.
//

import Foundation
import RxFlow
import Domain

enum ButtonType{
    case today_problem(CodestackStep?)
    case recommand_problem(CodestackStep?)
    case none
}


enum CodestackStep: Step, CaseIterable {
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
    case userLoggedIn(String?,Pwd?)
    case logout
    
    // Register Flow
    case register
    case email
    case password
    case additionalInfo
    case registerDissmiss(MemberVO)
    case exitRegister
    case registerSuccess(MemberVO)
    
    
    //myPage
    case profilePage
    case profileEdit(MemberVO, Data)
    case profileEditDissmiss
    
    //Home Step
    case firstHomeStep
    case projectHomeStep
    
    //problemSolve VC
    case problemComplete
    case problemList
    case problemPick(ProblemListItemModel)
    case recentSolveList(ProblemListItemModel?)
    case toastMessage(String)
    case toastV2Message(ToastStyle, String)
    case recommendPage
    
    case sideMenuDelegate(String)
    case sideShow
    case sideDissmiss
    
    
    case codestack
    
    case historyflow
    case richText(String)
    
    case none
    
}

extension CodestackStep: Equatable{
}
