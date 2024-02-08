//
//  CodeProblemViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Global

public typealias CurrentPage = Int

class CodeProblemViewController: UIViewController, UITableViewDelegate {
    
    struct Dependencies{
        var viewModel: (any ProblemViewModelProtocol)?
    }
    
    var viewModel: (any ProblemViewModelProtocol)?
    
    static func create(with dependencies: Dependencies) -> Self{
        let code = CodeProblemViewController()
        code.viewModel = dependencies.viewModel
        return code as! Self
    }
    
    lazy var problemTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(ProblemCell.self, forCellReuseIdentifier: ProblemCell.identifier)
        tableView.estimatedRowHeight = 200
        tableView.separatorColor = UIColor.clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = .init(top: 0, left: 0, bottom: 50, right: 0)
        return tableView
    }()
    
    lazy var segmentControl: UISegmentedControl = {
        let titles = ["0","1"]
        let segmentControl = UISegmentedControl(items: titles)
        segmentControl.tintColor = UIColor.white
        segmentControl.backgroundColor = UIColor.blue
        segmentControl.selectedSegmentIndex = 0
        segmentControl.setImage(UIImage(systemName: "rectangle"), forSegmentAt: 0)
        segmentControl.setImage(UIImage(systemName: "list.bullet"), forSegmentAt: 1)
        for index in 0...titles.count - 1 {
            segmentControl.setWidth(50, forSegmentAt: index)
        }
        return segmentControl
    }()
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindingModel()
        
        layoutConfigure()
    }
    
    //MARK: - View Layout Configure
    private func layoutConfigure(){
        self.view.backgroundColor = UIColor.systemBackground
        self.navigationItem.title = "문제"
        self.view.addSubview(problemTableView)
        problemTableView.snp.makeConstraints{
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            $0.bottom.equalTo(view.snp.bottom).offset(50)
        }
        segmentControl.sizeToFit()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: segmentControl)
    }
    
    
    //MARK: - Binding from ViewModel
    private var disposeBag: DisposeBag = DisposeBag()
    private var deinitVC = PublishRelay<Void>()
    private var _foldButtonSeleted = PublishRelay<(Int,Bool)>()
    private var _cellSelect = PublishRelay<DummyModel>()
    
    var _fetchProblemList = PublishRelay<Void>()
        
    lazy var _segmentcontrolValue = segmentControl.rx.selectedSegmentIndex.asSignal(onErrorJustReturn: 0)
    
    lazy var input = CodeProblemViewModel.Input(viewDidLoad: OB.justVoid(),
                                                deinitVC: deinitVC.asSignal(),
                                                segmentIndex: _segmentcontrolValue,
                                                foldButtonSeleted: _foldButtonSeleted.asSignal(),
                                                cellSelect: _cellSelect.asSignal(),
                                                fetchProblemList: _fetchProblemList.asSignal())
    
    var output: CodeProblemViewModel.Output?
    
    
    deinit {
        deinitVC.accept(())
        Log.debug("deinit ProblemVC")
    }
    #if DEBUG
//    func cellClickedEvent(){
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: { [weak self] in
//            guard let self else {return}
//            self._cellSelect.accept(())
//        })
//    }
    #endif
    
    private func bindingModel(){
        let viewmodel = (viewModel as? CodeProblemViewModel)
        self.output = viewmodel?.transform(input)
        
        let scroll = problemTableView.rx.didScroll.asObservable().skip(1)
        
        output?.refreshEndEvnet
            .drive(with: self,onNext: { vc, _ in
                vc.problemTableView.removeBottomRefresh()
            }).disposed(by: disposeBag)
        
        scroll
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .compactMap { vc, _ in vc.viewModel }
            .filter { vm in !vm.isLoading }
            .withUnretained(self)
            .map { vc, _ in vc.problemTableView }
            .filter { table in
                (table.contentOffset.y + 300) > (table.contentSize.height - table.bounds.height)
            }
            .subscribe(with: self, onNext: { vc, _ in
                vc.viewModel?.isLoading = true
                vc.problemTableView.addBottomRefresh(width: vc.view.frame.width)
                vc._fetchProblemList.accept(())
            }).disposed(by: disposeBag)
    
        problemTableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        guard let seg_list_model = self.output?.seg_list_model.asObservable() else {return}
        
        seg_list_model.bind(to: problemTableView.rx.items(cellIdentifier: ProblemCell.identifier,
                                                          cellType: ProblemCell.self))
        { [weak self] (index: Int, model : DummyModel ,cell: ProblemCell) in
        
            var dummyModel = model
            
            if let viewmodel {
                dummyModel.flag = viewmodel.animationSelected[dummyModel.model.problemNumber] ?? false
            }
            
            cell.binder.onNext(dummyModel)
            
            self?.problemTableView.showsVerticalScrollIndicator = true
            
            cell.foldButtonTap?.asObservable().bind(onNext: { [weak self] in
                guard let self = self else { return }
                self.problemTableView.showsVerticalScrollIndicator = false
                let buttonSelected = cell.foldButton.isSelected
                self.viewModel?.animationSelected[dummyModel.model.problemNumber] = buttonSelected
                self.problemTableView.performBatchUpdates({}){ value in
                    self.problemTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                }
            }).disposed(by: cell.disposeBag)

            
            guard let self else { return }
            cell.problemCell_tapGesture?.rx.event
                .asSignal()
                .map { _ in model }
                .emit(to: _cellSelect)
                .disposed(by: cell.disposeBag)
            
        }.disposed(by: disposeBag)
    }
    
    func moveFunc(){
#if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
            guard let self else {return}
            if let _ = problemTableView.cellForRow(at: IndexPath(row: 1, section: 0)){
                let vc = CodeEditorViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
#endif
    }
}
