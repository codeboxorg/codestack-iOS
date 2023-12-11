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
        var contiributionViewModel: ContributionViewModel?
        var sidemenuVC: SideMenuViewController
    }
    
    // ViewController
    private var homeViewModel: (any HomeViewModelType)?
    private(set) var contiributionViewModel: ContributionViewModel?
    private weak var sidemenuViewController: SideMenuViewController?
    
    static func create(with dependencies: Dependencies) -> ViewController{
        let vc = ViewController()
        vc.homeViewModel = dependencies.homeViewModel
        vc.sidemenuViewController = dependencies.sidemenuVC
        vc.contiributionViewModel = dependencies.contiributionViewModel
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
        let graph = GraphView(frame: .zero)
        graph.backgroundColor = graphBackground
        return graph
    }()
    
    let graphContainerView: UIView = {
       let view = UIView()
        return view
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
        button.tintColor = buttonTintColor
        return button
    }()
    
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        return label.headLineLabel(size: 16, text: "💡문제를 풀러 가볼까요?", color: labelColor)
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
    
    
    private var titleTextAttributesColor: UIColor { .clear }
    
    var graphBackground: UIColor {
        .systemBackground
    }
    
    private var buttonTintColor: UIColor {
        .sky_blue
    }
    
    private var labelColor: UIColor {
        .label
    }
    
    func settingColor() {
        self.view.backgroundColor = .systemBackground
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingColor()
        navigationSetting()
        layoutConfigure()
        
        //MARK: This is SwiftUI View
        calendarView()
        
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
        let viewDidLoad = _viewDidLoad.asSignal()
        let problemButtonEvent = mainView.emitTodayAndRecommendBtnEvent()
        let rightSwipeGesture = view.rx.gesture(.swipe(direction: .right)).when(.recognized).asObservable().map { _ in  }
        let leftSwipeGesture = view.rx.gesture(.swipe(direction: .left)).when(.recognized).asObservable().map { _ in  }
        let leftNavigationButtonEvent = navigationItem.leftBarButtonItem?.rx.tap.asSignal() ?? .never()
        
        let recentModelSelected
        =
        recentPagesCollectionView.rx
            .modelSelected(Submission.self)
            .asSignal()
            .throttle(.seconds(1), latest: false)
            .map { print("touch value"); return $0 }
        
        let emptyDataButton = emptyDataButton.rx.tap.asSignal()
        let alramTapped = alramView.rx.gesture(.tap()).when(.recognized).asObservable().map { _ in}
        
        let output =
        (homeViewModel as! HomeViewModel)
            .transform(input: HomeViewModel.Input(viewDidLoad: viewDidLoad,
                                                  problemButtonEvent: problemButtonEvent,
                                                  rightSwipeGesture: rightSwipeGesture,
                                                  leftSwipeGesture: leftSwipeGesture,
                                                  leftNavigationButtonEvent: leftNavigationButtonEvent,
                                                  recentModelSelected: recentModelSelected,
                                                  emptyDataButton: emptyDataButton,
                                                  alramTapped: alramTapped))
        
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
                    switch section {
                    case UICollectionView.elementKindSectionHeader:
                        guard 
                            let header = collectionView
                                .dequeueReusableSupplementaryView(ofKind: section,
                                                                  withReuseIdentifier: RecentSectionHeader.identifier,
                                                                  for: indexPath) as? RecentSectionHeader
                        else { return UICollectionReusableView() }
                        let title = dataSource.sectionModels[indexPath.section].headerTitle
                        header.settingHeader("\(title)")
                        return header
                    default:
                        fatalError()
                    }
                }
        )
        
        output.submissions
            .compactMap { $0.first?.items.isEmpty }
            .drive(with: self, onNext: {vc, flag in
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
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: nil)
        
        // back navigtion 백버튼 타이틀 숨기기
        let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: titleTextAttributesColor]
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backButtonAppearance = backButtonAppearance
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
    }
    
    
    //MARK: -추후 viewComponent 분리 필요
    private func layoutConfigure(){
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(containerView)
        containerView.addSubview(graphContainerView)
        containerView.addSubview(mainView)
        containerView.addSubview(recentPagesCollectionView)
        containerView.addSubview(imgView)
        
        graphContainerView.addSubview(graphView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges)
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
            make.height.equalTo(1000).priority(.low)
        }
        
        //TODO: 추후 Line graph와 비교 해서 change 할 수 있게 구성 고려
        graphView.isHidden = true
        graphContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().inset(12)
            make.height.equalTo(300)
        }
        
        graphView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        recentPagesCollectionView.snp.makeConstraints{
            $0.top.equalTo(graphContainerView.snp.bottom).offset(24)
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

