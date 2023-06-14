//
//  MainViewControllerFlow.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/08.
//

import Foundation
import RxFlow
import RxSwift
import RxCocoa

class HomeFlow: Flow{
    
    var root: RxFlow.Presentable{
        self.rootViewController
    }
    
    let viewModel: any HomeViewModelProtocol
    private lazy var rootViewController = ViewController.create(with: viewModel)
    private lazy var containerScreen = ContainerViewController(sideMenuViewController: sideMenuViewController)
//    let codePRListScreen = CodeProblemViewController.create(with: .init(viewModel: CodeProblemViewModel() as (any ProblemViewModelProtocol) ))
    
    let testScreen = TestViewController()
    
    init(dependencies: any HomeViewModelProtocol){
        self.viewModel = dependencies
    }
    
    lazy var items: [SideMenuItem] = [SideMenuItem(icon: UIImage(named: "problem"),
                                              name: "문제"),
                                 SideMenuItem(icon: UIImage(named: "submit"),
                                              name: "제출근황"),
                                 SideMenuItem(icon: UIImage(named: "my"),
                                              name: "마이 페이지"),
                                 SideMenuItem(icon: UIImage(named: "home"),
                                              name: "메인 페이지"),
                                 SideMenuItem(icon: nil, name: "추천")]
    
    lazy var sideMenuViewController = SideMenuViewController(sideMenuItems: items)
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        guard let codestackStep = step as? CodestackStep else {return .none}
        
        switch codestackStep {
        case .firstHomeStep:
            return .none
        case .problemList:
            return navigateToProblemList()
        case .problemPick(let _):
            return .none
        case .alert(let _):
            return .none
        case .fakeStep:
            return .none
        case .unauthorized:
            return .none
        case .loginNeeded:
            return .none
        case .sideMenuDelegate(let _):
            return .none
        default:
            print("codestackStep: \(codestackStep)")
            return .none
        }
    }
    
//    private func navigateToHomeScreen() -> FlowContributors{
//        return .one(flowContributor: .contribute(withNextPresentable: <#T##Presentable#>, withNextStepper: <#T##Stepper#>))
//    }
    
    private func navigateToProblemList() -> FlowContributors{
//        CompositeStepper(steppers: [viewController.viewModel, viewController])
        let viewModel = CodeProblemViewModel(DummyData())
        let codeListFlow = CodeProblemListFlow(dependencies: viewModel)
        let stepper = CodeProblemStepper()
        
        Flows.use(codeListFlow, when: .created, block: {flowRoot in
            self.rootViewController.navigationController?.pushViewController(flowRoot, animated: false)
        })
        
        return .one(flowContributor: .contribute(withNextPresentable: codeListFlow,
                                                 withNextStepper: CompositeStepper(steppers: [stepper,viewModel])))
    }
}
