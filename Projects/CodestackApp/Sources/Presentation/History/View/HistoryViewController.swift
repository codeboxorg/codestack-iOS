//
//  TestViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/19.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class HistoryViewController: UIViewController, UITableViewDelegate {
    
    var historyViewModel: (any HistoryViewModelType)?
    
    static func create(with dependency: any HistoryViewModelType) -> HistoryViewController {
        let history = HistoryViewController()
        history.historyViewModel = dependency as? HistoryViewModel
        return history
    }
    
    private let container: ContainerView = {
        let view = ContainerView(frame: .zero)
        view.backgroundColor = .tertiarySystemBackground
        return view
    }()
    
    private let historySegmentList: HistorySegmentedControl = {
        let seg = HistorySegmentedControl(frame: .zero)
        return seg
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.tintColor = UIColor.sky_blue
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        return button
    }()
    
    private let historyList: UITableView = {
        let table = UITableView(frame: .zero)
        table.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.identifier)
        table.alwaysBounceVertical = false
        return table
    }()
    
    
    
    private var disposeBag = DisposeBag()
    private var _viewDidLoad = PublishSubject<Void>()
    private var fetchHistoryList = PublishRelay<Void>()
    private var paginationLoadingInput = PublishRelay<Bool>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutConfigure()
        binding()
        _viewDidLoad.onNext(())
    }
    
    func binding(){
        
        let rightGesture = historyList.rx.gesture(.swipe(direction: .right))
            .withUnretained(self)
            .compactMap{ vc, _ in
                if vc.historySegmentList.selectedSegmentIndex != 0{
                    vc.historySegmentList.selectedSegmentIndex -= 1
                    return vc.historySegmentList.selectedSegmentIndex
                }
                return nil
            }.asDriver(onErrorJustReturn: 0)
        
        
        let leftGesture = historyList.rx.gesture(.swipe(direction: .left))
            .withUnretained(self)
            .compactMap{ vc, _ in
                if vc.historySegmentList.selectedSegmentIndex != 4{
                    vc.historySegmentList.selectedSegmentIndex += 1
                    return vc.historySegmentList.selectedSegmentIndex
                }
                return nil
            }.asDriver(onErrorJustReturn: 0)
        
        
        let historyDriver = historySegmentList.rx.selectedSegmentIndex.asDriver()
        
        let historySegmentUtil = Driver.merge([rightGesture,leftGesture,historyDriver])
        
        historySegmentUtil
            .drive(with: self,
                   onNext: { vm, _ in
                vm.historySegmentList.setNeedsDisplay()
            }).disposed(by: disposeBag)
        
        
        let currentSegment
        =
        historySegmentUtil.map { value in
            let segTypeValue = SegType.Value(rawValue: value) ?? SegType.Value.all
            return segTypeValue
        }.asDriver()
        
        
        let output
        =
        (historyViewModel as! HistoryViewModel)
            .transform(input:
                        HistoryViewModel.Input(viewDidLoad: _viewDidLoad.asSignal(onErrorJustReturn: ()),
                                               currentSegment: currentSegment,
                                               refreshTap: refreshButton.rx.tap.asSignal(),
                                               fetchHistoryList: fetchHistoryList.asSignal(),
                                               paginationLoadingInput: paginationLoadingInput.asSignal()))
        
        output.historyData
            .drive(historyList.rx.items(cellIdentifier: HistoryCell.identifier,
                                        cellType: HistoryCell.self))
        {  index , submission , cell in
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets.zero
            cell.onHistoryData.accept(submission)
            cell.onStatus.accept(submission.statusCode.convertSolveStatus() )
        }.disposed(by: disposeBag)
        
        
        output.paginationRefreshEndEvent
            .emit(with: self,onNext: { vc, _ in
                vc.historyList.removeBottomRefresh()
            }).disposed(by: disposeBag)
        
        
        let paginationLoding = output.paginationLoading.asObservable()
        let scroll = historyList.rx.didScroll.asDriver()
        
        historyList.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        output.refreshClearEvent
            .emit(with: self,onNext: { vc, value in
                Toast.toastMessage("...새로고침 완료...",
                                   offset: UIScreen.main.bounds.height - 250,
                                   background: .sky_blue,
                                   boader: UIColor.black.cgColor)
            }).disposed(by: disposeBag)

        Driver.combineLatest(scroll, currentSegment)
            .throttle(.milliseconds(500))
            .filter { $1.isAll() }
            .flatMapLatest{ _ in paginationLoding.take(1).asDriver(onErrorJustReturn: false) }
            .filter { !$0 }
            .drive(with: self,onNext: { vc , _ in
                let table = vc.historyList
                if table.contentOffset.y > table.contentSize.height - table.bounds.height{
                    table.addBottomRefresh(width: vc.view.frame.width)
                    vc.paginationLoadingInput.accept(true)
                    vc.fetchHistoryList.accept(())
                }
            }).disposed(by: disposeBag)
    }
}

//MARK: - Layout configure
extension HistoryViewController{
    
    func layoutConfigure(){
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: refreshButton)
        self.view.backgroundColor = .tertiarySystemBackground
        
        view.addSubview(container)
        view.addSubview(historyList)
        container.addSubview(historySegmentList)
        historySegmentList.selectedSegmentIndex = SegType.Value.all.rawValue
        
        
        historyList.snp.makeConstraints{
            $0.top.equalTo(container.snp.bottom).offset(12)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        self.view.backgroundColor = .tertiarySystemBackground
        
        container.snp.makeConstraints{
            $0.height.equalTo(44)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
        }
        
        historySegmentList.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-50)
            $0.bottom.equalToSuperview()
        }
    }
}

extension HistoryViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
    -> Bool {
        return false
    }
}
