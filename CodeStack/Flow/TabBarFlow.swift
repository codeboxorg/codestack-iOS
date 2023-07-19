//
//  MainViewControllerFlow.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/08.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa

class TabBarFlow: Flow{
    
    var root: RxFlow.Presentable{
        self.rootViewTabController
    }
    
    
    private var rootViewTabController = CustomTabBarController()
    
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        guard let codestackStep = step as? CodestackStep else {return .none}
        
        switch codestackStep {
        case .logout:
            return .end(forwardToParentFlowWithStep: CodestackStep.logout)
        case .firstHomeStep:
            return navigateToTabBarController()
        case .alert(_):
            return .none
        case .fakeStep:
            return .none
        case .problemList:
            rootViewTabController.selectedIndex = 1
            return .none
        default:
            print("codestackStep: \(codestackStep)")
            return .none
        }
    }
    
    private func navigateToTabBarController() -> FlowContributors{
        let homeFlow = HomeFlow(delegate: rootViewTabController)
        let problemFlow = CodeProblemFlow()
        let historyFlow = HistoryFlow()
        let myPageFlow = MyPageFlow()
        
        Flows.use(homeFlow,problemFlow,historyFlow,myPageFlow, when: .created)
        { [unowned self] home,problem,histoty,myPage in
            let homeVC = home
            let problemVC = problem
            let historyVC = histoty
            let myPageVC = myPage
            
            homeVC.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 0)
            problemVC.tabBarItem = UITabBarItem(title: "문제", image: UIImage(systemName: "list.bullet.rectangle.portrait"), tag: 1)
            historyVC.tabBarItem = UITabBarItem(title: "기록", image: UIImage(systemName: "clock"), tag: 2)
            myPageVC.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(systemName: "person"), tag: 3)
            
            self.rootViewTabController.setViewControllers([homeVC,
                                                           problemVC,
                                                           historyVC,
                                                           myPageVC], animated: true)
         
        }
        
        return .multiple(flowContributors: [
            .contribute(withNextPresentable: homeFlow, withNextStepper: HomeStepper()),
            .contribute(withNextPresentable: problemFlow, withNextStepper: ProblemStepper()),
            .contribute(withNextPresentable: historyFlow, withNextStepper: OneStepper(withSingleStep: CodestackStep.historyflow)),
            .contribute(withNextPresentable: myPageFlow, withNextStepper: OneStepper(withSingleStep: CodestackStep.profilePage))
        ])
    }
}


