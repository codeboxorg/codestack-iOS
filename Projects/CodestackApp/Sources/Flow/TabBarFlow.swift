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
    
    struct Dependency {
        let loginservice: OAuthrizationRequest
        let authService: AuthServiceType
        let apolloService: WebRepository
    }
    
    init(dependency: Dependency){
        self.loginService = dependency.loginservice
        self.authService = dependency.authService
        self.apolloService = dependency.apolloService
    }
    
    private var rootViewTabController = CustomTabBarController()
    
    private let loginService: CodestackAuthorization
    private let authService: AuthServiceType
    private let apolloService: WebRepository
    private let dbRepository: DBRepository = DefaultDBRepository(persistenStore: CoreDataStack(version: 1))
    
    private lazy var submissionUseCase: SubmissionUseCase 
    = DefaultSubmissionUseCase(dbRepository: dbRepository,
                               webRepository: apolloService)
    
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
        let homeViewModel = HomeViewModel(dependency: .init(repository: dbRepository,
                                                            service: apolloService))
        let tabBarDelegate = rootViewTabController
        
        let historyViewModel = HistoryViewModel(dependency: .init(service: apolloService,
                                                                  submisionUsecase: submissionUseCase))
        
        let codeDependency = CodeProblemFlow.Dependency(apolloService: apolloService,
                                                        homeViewModel: homeViewModel,
                                                        historyViewModel: historyViewModel,
                                                        dbRepository: dbRepository,
                                                        submissionUseCase: submissionUseCase)
        
        let homeDependency = HomeFlow.Dependency(tabbarDelegate: tabBarDelegate,
                                                 apolloService: apolloService,
                                                 homeViewModel: homeViewModel,
                                                 historyViewModel: historyViewModel,
                                                 dbRepository: dbRepository,
                                                 submissionUseCase: submissionUseCase)
        
        let myPageDependency = MyPageFlow.Dependency(apolloService: apolloService,
                                                     authService: authService)
        
        let homeFlow = HomeFlow(dependency: homeDependency)
        let problemFlow = CodeProblemFlow(dependency: codeDependency)
        let historyFlow = HistoryFlow(historyViewModel: historyViewModel)
        let myPageFlow = MyPageFlow(dependency: myPageDependency)
        
        Flows.use(homeFlow,problemFlow,historyFlow,myPageFlow, when: .created)
        { [unowned self] home,problem,histoty,myPage in
            let homeVC = home
            let problemVC = problem
            let historyVC = histoty
            let myPageVC = myPage
            
            homeVC.tabBarItem = UITabBarItem(title: nil,
                                             image: UIImage(systemName: "house")?.baseOffset(),
                                             tag: 0)
            
            problemVC.tabBarItem = UITabBarItem(title: nil,
                                                image: UIImage(systemName: "list.bullet.rectangle.portrait")?.baseOffset(),
                                                tag: 1)
            
            historyVC.tabBarItem = UITabBarItem(title: nil,
                                                image: UIImage(systemName: "clock")?.baseOffset(),
                                                tag: 2)
            
            myPageVC.tabBarItem = UITabBarItem(title: nil,
                                               image: UIImage(systemName: "person")?.baseOffset(),
                                               tag: 3)
            
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


