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

class HistoryViewController: UIViewController {
    
    
    private lazy var container: ContainerView = {
        let view = ContainerView(frame: .zero)
        view.backgroundColor = .tertiarySystemBackground
        return view
    }()
    
    var historySegmentList: HistorySegmentedControl = {
        let seg = HistorySegmentedControl(frame: .zero)
        return seg
    }()

    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .tertiarySystemBackground
        
        view.addSubview(container)
        container.addSubview(historySegmentList)
        historySegmentList.selectedSegmentIndex = 0
        
        historySegmentList.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] value in
                guard let self else {return}
                self.historySegmentList.setNeedsDisplay()
            }).disposed(by: disposeBag)
        
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
