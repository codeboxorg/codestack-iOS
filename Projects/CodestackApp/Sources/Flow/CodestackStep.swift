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
    
    
    // TabBar middle button
    case writeSelectStep
    case postingWrtieStep
    case markDownPreview(String)
    case postingEndStep
    case postEditorStep
    case postTagAddStep
    
    // TabBar middle button & editor
    case codeEditorStep(CodeEditor)
    
    //problemSolve VC
    case problemLink(URL)
    case problemComplete
    case problemList
    case problemPick(ProblemSolveEditor)
    case codeEditor(CodeEditor)
    case recentSolveList(ProblemSolveEditor)
    
    case toastMessage(String)
    case toastV2Message(ToastStyle, String)
    case toastV2Value(ToastValue)
    
    case recommendPage
    
    case sideMenuDelegate(String)
    case sideShow
    case sideDissmiss
    
    
    case codestack
    
    case historyflow
    case richText(String, StoreVO)
    
    case none
    
}
