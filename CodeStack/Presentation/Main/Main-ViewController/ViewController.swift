//
//  ViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit
import SnapKit
import RxFlow
import RxSwift
import RxRelay
import RxGesture


extension UIViewController {
    func adjustLargeTitleSize() {
        self.title = "CodeStack"
        self.navigationController?.navigationBar.tintColor = UIColor.label
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        
    }
}

typealias HomeViewController = ViewController


class ViewController: UIViewController{
    
    //    weak var delegate: SideMenuDelegate?
    
    struct Dependencies{
        var homeViewModel: any HomeViewModelProtocol
        var sidemenuVC: SideMenuViewController
    }
    
    //ViewController
    private var homeViewModel: (any HomeViewModelProtocol)?
    private weak var sidemenuViewController: SideMenuViewController?
    
    static func create(with dependencies: Dependencies) -> ViewController{
        let vc = ViewController()
        vc.homeViewModel = dependencies.homeViewModel
        vc.sidemenuViewController = dependencies.sidemenuVC
        return vc
    }
    
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private lazy var recentPagesCollectionView: UICollectionView = {
        let collectionView = PRSubmissionHistoryCell.submissionHistoryCellSetting(item: CGSize(width: 140, height: 140),
                                                                                  background: UIColor.systemBackground)
        collectionView.register(PRSubmissionHistoryCell.self, forCellWithReuseIdentifier: PRSubmissionHistoryCell.identifier)
        return collectionView
    }()
    
    private let mainView: MainView = {
        let view = MainView(frame: .zero, stepType: [.problemList,.fakeStep])
        return view
    }()
    
    private lazy var graphView: GraphView = {
        let graph = GraphView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width - 24, height: .zero))
        return graph
    }()
    
    
    private lazy var alramView: RightAlarmView = {
        let view = RightAlarmView()
        return view
    }()
    
    
    private var _viewDidLoad = PublishRelay<Void>()
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetting()
        layoutConfigure()
        binding()
        
        view.gestureRecognizers?.forEach{
            $0.delegate = self
        }
        
        // SideMenu ViewController setting
        if let sidemenuViewController{
            addChild(sidemenuViewController)
            view.addSubview(sidemenuViewController.view)
            sidemenuViewController.didMove(toParent: self)
        }
        
        _viewDidLoad.accept(())
    }
    
    private func binding(){
        let output = (homeViewModel as! HomeViewModel).transform(input: HomeViewModel.Input(viewDidLoad: _viewDidLoad.asSignal(),
                                                                                            problemButtonEvent: mainView.emitButtonEvents(),
                                                                                            rightSwipeGesture: view.rx.gesture(.swipe(direction: .right)).when(.recognized).asObservable(),
                                                                                            leftSwipeGesture: view.rx.gesture(.swipe(direction: .left)).when(.recognized).asObservable(),
                                                                                            leftNavigationButtonEvent: navigationItem.leftBarButtonItem?.rx.tap.asSignal() ?? .never(),
                                                                                            recentProblemPage: recentPagesCollectionView.rx.modelSelected(Submission.self).asSignal(),
                                                                                            alramTapped: alramView.rx.gesture(.tap()).when(.recognized).asObservable()))
        output.submissions
            .drive(recentPagesCollectionView.rx.items(cellIdentifier: PRSubmissionHistoryCell.identifier,
                                                      cellType: PRSubmissionHistoryCell.self))
        {  index, item , cell in
            cell.onRecentPageData.accept(item)
            cell.onStatus.accept(SolveStatus.allCases.randomElement()!)
            
        }.disposed(by: disposeBag)
    }
    
    
    private func navigationSetting(){
        //라지 타이틀 적용
        adjustLargeTitleSize()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: alramView)
        // 사이드바 보기 버튼 적용
        self.view.backgroundColor = UIColor.systemBackground
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: nil)
        
        // back navigtion 백버튼 타이틀 숨기기
        let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backButtonAppearance = backButtonAppearance
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
    }
    
    
    //MARK: -추후 viewComponent 분리 필요
    private func layoutConfigure(){
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(containerView)
        containerView.addSubview(graphView)
        containerView.addSubview(mainView)
        containerView.addSubview(recentPagesCollectionView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges)
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
            make.height.equalTo(1000).priority(.low)
        }
        
        graphView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(200)
        }
        
        
        recentPagesCollectionView.snp.makeConstraints{
            $0.top.equalTo(graphView.snp.bottom).offset(24)
            $0.width.equalTo(mainView.snp.width)
            $0.height.equalTo(180)
        }
        
        mainView.snp.makeConstraints{
            $0.top.equalTo(recentPagesCollectionView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(self.mainView.container_height).priority(.low)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
}


extension ViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
    -> Bool {
        return false
    }
}
