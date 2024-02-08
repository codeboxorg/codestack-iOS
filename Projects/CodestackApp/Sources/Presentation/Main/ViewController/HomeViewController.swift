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
import Global
import Domain
import CommonUI

//typealias HomeViewController = ViewController


final class HomeViewController: UIViewController {
    
    struct Dependencies{
        var homeViewModel: any HomeViewModelType
        var sidemenuVC: SideMenuViewController
    }
    
    // ViewController
    private var homeViewModel: (any HomeViewModelType)?
    weak var sidemenuViewController: SideMenuViewController?
    
    static func create(with dependencies: Dependencies) -> HomeViewController {
        let vc = HomeViewController()
        vc.homeViewModel = dependencies.homeViewModel
        vc.sidemenuViewController = dependencies.sidemenuVC
        return vc
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInset = .init(top: 0, left: 0, bottom: 50, right: 0)
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
        let graph = GraphView(frame: .zero)
        graph.backgroundColor = .systemBackground
        return graph
    }()
    
    
    let alramView = RightAlarmView()
    
    private lazy var emptyDataButton = AddGradientView()
    
    
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
    
    private var disposeBag = DisposeBag()
    
    
    func settingColor() {
        self.view.backgroundColor = .systemBackground
    }
    
    deinit {
        Log.debug("homeViewCOntroller Deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingColor()
        navigationSetting()
        
        // MARK: LAyout Setting 3 phase
        layoutConfigure()
        
        // MARK: SideMenu ViewController Setting
        sideMenuVCSetting()
        
        binding()
        
        view.gestureRecognizers?.forEach { $0.delegate = self }
        
        mainView.skeletonLayout()
    }
    
    
    private func binding(){
        let problemButtonEvent = mainView.emitTodayAndRecommendBtnEvent()
        let rightSwipeGesture = view.rx.gesture(.swipe(direction: .right)).when(.recognized).asObservable().map { _ in  }
        let leftSwipeGesture = view.rx.gesture(.swipe(direction: .left)).when(.recognized).asObservable().map { _ in  }
        let leftNavigationButtonEvent = navigationItem.leftBarButtonItem?.rx.tap.asSignal() ?? .never()
        
        let recentModelSelected
        =
        recentPagesCollectionView.rx
            .modelSelected(HomeSection.HomeItem.self)
            .asSignal()
            .throttle(.seconds(1), latest: false)
    
        
        let emptyDataButton = emptyDataButton.rx.tap.asSignal()
        let alramTapped = alramView.rx.gesture(.tap()).when(.recognized).asObservable().map { _ in}
        
        let output =
        (homeViewModel as! HomeViewModel)
            .transform(input: HomeViewModel.Input(viewDidLoad: OB.justVoid(),
                                                  problemButtonEvent: problemButtonEvent,
                                                  rightSwipeGesture: rightSwipeGesture,
                                                  leftSwipeGesture: leftSwipeGesture,
                                                  leftNavigationButtonEvent: leftNavigationButtonEvent,
                                                  recentModelSelected: recentModelSelected,
                                                  emptyDataButton: emptyDataButton,
                                                  alramTapped: alramTapped))

        let datasource = recentSubmissionDataSource()
        
        output.homeDataModel
            .map { datas in datas.filter { $0.model == .recent }.flatMap(\.items) }
            .map { $0.count <= 1 }
            .drive(with: self, onNext: { vc, value in
                value ? vc.makeEmptyView() : vc.restoreEmptyView()
            }).disposed(by: disposeBag)
        
        output.homeDataModel
            .drive(recentPagesCollectionView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
    }
}

// MARK: Data Source
extension HomeViewController {
    func recentSubmissionDataSource() -> RxCollectionViewSectionedReloadDataSource<HomeSection.HomeSectionModel> {
        RxCollectionViewSectionedReloadDataSource<HomeSection.HomeSectionModel>(
            configureCell:
                { datasource, collectionView, indexPath, item in
                    switch item {
                    case .recent(let recentItem):
                        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PRSubmissionHistoryCell.identifier, for: indexPath) as? PRSubmissionHistoryCell else {
                            return UICollectionViewCell()
                        }
                        
                        if recentItem.isSample {
                            cell.isHidden = true
                            return cell
                        } else { cell.isHidden = false }
                        
                        cell.binder.onNext((recentItem))
                        return cell
                        
                    case .writingList(let store):
                        guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WritingListCell.identifier, for: indexPath) as? WritingListCell else {
                            return UICollectionViewCell()
                        }
                        cell.binder.onNext(store)
                        return cell
                    }
                },
            configureSupplementaryView:
                { dataSource, collectionView, section, indexPath in
                    switch section {
                    case UICollectionView.elementKindSectionHeader:
                        // let value = dataSource.sectionModels[indexPath.section]
                        guard
                            let header = collectionView
                                .dequeueReusableSupplementaryView(ofKind: section,
                                                                  withReuseIdentifier: RecentSectionHeader.identifier,
                                                                  for: indexPath) as? RecentSectionHeader else {
                            return UICollectionReusableView()
                        }
                        let title = dataSource.sectionModels[indexPath.section]
                        header.settingHeader("\(title.model.rawValue)")
                        return header
                    default:
                        fatalError()
                    }
                }
        )
    }
}


extension HomeViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}


//MARK: - Layout Configure , setting func
extension HomeViewController{
    private func makeEmptyView(){
        self.recentPagesCollectionView.addSubview(emptyDataButton)
        self.recentPagesCollectionView.addSubview(emptyLabel)
        
        emptyDataButton.snp.makeConstraints { make in
            make.centerX.equalTo(recentPagesCollectionView.snp.centerX)
            make.top.equalTo(recentPagesCollectionView.snp.top).offset(60)
            make.width.height.equalTo(50).priority(.high)
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyDataButton.snp.bottom).offset(8)
        }
    }
    
    private func restoreEmptyView(){
        self.emptyDataButton.removeFromSuperview()
        self.emptyLabel.removeFromSuperview()
    }
    
    //MARK: -추후 viewComponent 분리 필요
    private func layoutConfigure(){
        view.addSubview(scrollView)
        
        scrollView.addSubview(containerView)
        
        containerView.addSubview(mainView)
        containerView.addSubview(recentPagesCollectionView)
        containerView.addSubview(imgView)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.snp.bottom).offset(50)
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
            make.height.equalTo(1000).priority(.low)
        }
        
        //TODO: 추후 Line graph와 비교 해서 change 할 수 있게 구성 고려
        graphView.isHidden = true
        
        recentPagesCollectionView.snp.makeConstraints{
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            $0.height.equalTo(440).priority(.low)
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

