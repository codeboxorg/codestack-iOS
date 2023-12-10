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
    case registerPage
    case register
    case registerDissmiss
    case userLoggedIn(ID?,Pwd?)
    case logout
    
    
    //myPage
    case profilePage
    case profileEdit
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
    case recommendPage
    
    case sideMenuDelegate(String)
    case sideShow
    case sideDissmiss
    
    
    case codestack
    
    case historyflow
    case richText([Problem])
    
    case none
    
}

extension CodestackStep: Equatable{
//    static func == (lhs: CodestackStep, rhs: CodestackStep) -> Bool{
//        switch (lhs, rhs) {
//        case (.recentSolveList(let list, _), .recentSolveList(let list2, _)):
//            guard let list,
//                  let list2
//            else {return false}
//            return list.problemNumber == list2.problemNumber
//        case (.logout,.logout):
//            return true
//        default:
//            return false
//        }
//    }
}
