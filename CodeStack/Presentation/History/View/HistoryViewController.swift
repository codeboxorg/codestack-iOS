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

class HistoryViewController: UIViewController {
    
    var historyViewModel: HistoryViewModel?
    
    static func create(with dependency: HistoryViewModel) -> HistoryViewController{
        let history = HistoryViewController()
        history.historyViewModel = dependency
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
    
    private let historyList: UITableView = {
        let table = UITableView(frame: .zero)
        table.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.identifier)
        return table
    }()
    
    var _viewDidLoad = PublishSubject<Void>()

    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutConfigure()
        binding()
        _viewDidLoad.onNext(())
    }
    
    func binding(){
        
        let rightGesture = historyList.rx.gesture(.swipe(direction: .right))
            .withUnretained(self)
            .map{ vc, _ in
                if vc.historySegmentList.selectedSegmentIndex != 0{
                    vc.historySegmentList.selectedSegmentIndex -= 1
                }
                return vc.historySegmentList.selectedSegmentIndex
            }.asDriver(onErrorJustReturn: 0)
        
        
        let leftGesture = historyList.rx.gesture(.swipe(direction: .left))
            .withUnretained(self)
            .map{ vc, _ in
                if vc.historySegmentList.selectedSegmentIndex != 4{
                    vc.historySegmentList.selectedSegmentIndex += 1
                }
                return vc.historySegmentList.selectedSegmentIndex
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
        historySegmentUtil.map{ value in
            SegType.switchSegType(value: SegType.Value(rawValue: value) ?? SegType.Value.all)
        }.asSignal(onErrorJustReturn: .all)
        
        
        guard let output = historyViewModel?
            .transform(input:
                        HistoryViewModel.Input(viewDidLoad: _viewDidLoad.asSignal(onErrorJustReturn: ()),
                                               currentSegment: currentSegment)) else { return }
        
        output.historyData
            .drive(historyList.rx.items(cellIdentifier: HistoryCell.identifier,
                                        cellType: HistoryCell.self))
        { index , value , cell in
            cell.publishRelay.accept(value)
        }.disposed(by: disposeBag)
        
    }
}


//MARK: - Layout configure
extension HistoryViewController{
    
    func layoutConfigure(){
        self.view.backgroundColor = .tertiarySystemBackground
        
        view.addSubview(container)
        view.addSubview(historyList)
        container.addSubview(historySegmentList)
        historySegmentList.selectedSegmentIndex = 0
        
        
        
        historyList.snp.makeConstraints{
            $0.top.equalTo(container.snp.bottom).offset(12)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
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
