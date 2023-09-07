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
import RxDataSources




extension UIViewController {
    func adjustLargeTitleSize(title: String = "Codestack") {
        //        self.title =
        self.navigationItem.title = title
        self.navigationController?.navigationBar.tintColor = UIColor.label
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        
    }
}

typealias HomeViewController = ViewController


class ViewController: UIViewController{
    
    struct Dependencies{
        var homeViewModel: any HomeViewModelType
        var sidemenuVC: SideMenuViewController
    }
    
    //ViewController
    private var homeViewModel: (any HomeViewModelType)?
    private weak var sidemenuViewController: SideMenuViewController?
    
    static func create(with dependencies: Dependencies) -> ViewController{
        let vc = ViewController()
        vc.homeViewModel = dependencies.homeViewModel
        vc.sidemenuViewController = dependencies.sidemenuVC
        return vc
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let mainView: MainView = {
        let view = MainView(frame: .zero, stepType: [.problemList,.recommendPage])
        return view
    }()
    
    private lazy var graphView: GraphView = {
        let graph = GraphView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width - 24, height: .zero))
        graph.backgroundColor = UIColor.systemBackground
        return graph
    }()
    
    private let alramView: RightAlarmView = {
        let view = RightAlarmView()
        return view
    }()
    
    private lazy var emptyDataButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .semibold)
        let image = UIImage(systemName: "plus.circle", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.sky_blue
        return button
    }()
    
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        return label.headLineLabel(size: 16, text: "💡문제를 풀러 가볼까요?", color: .label)
    }()
    
    
    private let recentPagesCollectionView: UICollectionView = {
        let collectionView = PRSubmissionHistoryCell.submissionHistoryCellSetting(background: UIColor.systemBackground)
        return collectionView
    }()
 
    
    
    private lazy var imgView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
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
        let output =
        (homeViewModel as! HomeViewModel)
            .transform(input: HomeViewModel.Input(viewDidLoad: _viewDidLoad.asSignal(),
                                                  problemButtonEvent: mainView.emitTodayAndRecommendBtnEvent(),
                                                  rightSwipeGesture: view.rx.gesture(.swipe(direction: .right)).when(.recognized).asObservable(),
                                                  leftSwipeGesture: view.rx.gesture(.swipe(direction: .left)).when(.recognized).asObservable(),
                                                  leftNavigationButtonEvent: navigationItem.leftBarButtonItem?.rx.tap.asSignal() ?? .never(),
                                                  recentProblemPage: recentPagesCollectionView.rx.modelSelected(Submission.self).asSignal(),
                                                  emptyDataButton: emptyDataButton.rx.tap.asSignal(),
                                                  alramTapped: alramView.rx.gesture(.tap()).when(.recognized).asObservable()))
        
        let dataSource =
        RxCollectionViewSectionedReloadDataSource<RecentSubmission>(
            configureCell:
                { datasource, collectionView, indexPath, item in
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PRSubmissionHistoryCell.identifier, for: indexPath) as? PRSubmissionHistoryCell else {return UICollectionViewCell()}
                    
                    cell.onRecentPageData.accept(item)
                    cell.onStatus.accept(item.statusCode?.convertSolveStatus() ?? .none)
                    return cell
                },
            configureSupplementaryView:
                { dataSource, collectionView, section, indexPath in
                    switch section{
                    case UICollectionView.elementKindSectionHeader:
                        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: section, withReuseIdentifier: RecentSectionHeader.identifier, for: indexPath)
                                as? RecentSectionHeader else { return UICollectionReusableView() }
                        let title = dataSource.sectionModels[indexPath.section].headerTitle
                        header.settingHeader("\(title)")
                        return header
                    default:
                        fatalError()
                    }
                }
        )
        
        output.submissions
            .compactMap{ $0.first?.items.isEmpty }
            .drive(with: self,onNext: {vc, flag in
                flag == true ? vc.makeEmptyView() : vc.restoreEmptyView()
            }).disposed(by: disposeBag)
        
        output.submissions
            .drive(recentPagesCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}


extension ViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
    -> Bool {
        return false
    }
}


//MARK: - Layout Configure , setting func
extension ViewController{
    private func makeEmptyView(){
        self.recentPagesCollectionView.addSubview(emptyDataButton)
        self.recentPagesCollectionView.addSubview(emptyLabel)
        
        emptyDataButton.snp.makeConstraints { make in
            make.centerX.equalTo(recentPagesCollectionView.snp.centerX)
            make.centerY.equalTo(recentPagesCollectionView.snp.centerY).offset(15)
            make.width.height.equalTo(50).priority(.high)
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyDataButton.snp.bottom).offset(8)
        }
        
        recentPagesCollectionView.snp.updateConstraints{ make in
            make.height.equalTo(150)
        }
    }
    
    private func restoreEmptyView(){
        self.emptyDataButton.removeFromSuperview()
        self.emptyLabel.removeFromSuperview()
        
        recentPagesCollectionView.snp.updateConstraints{ make in
            make.height.equalTo(200)
        }
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
        containerView.addSubview(imgView)
        
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
            $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            $0.height.equalTo(200)
        }
        
        mainView.snp.makeConstraints{
            $0.top.equalTo(recentPagesCollectionView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(self.mainView.container_height).priority(.low)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12)
        }
        
    }
}

