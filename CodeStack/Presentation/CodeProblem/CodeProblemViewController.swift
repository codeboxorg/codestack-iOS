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

public typealias CurrentPage = Int

class CodeProblemViewController: UIViewController, UITableViewDelegate{
    
    struct Dependencies{
//        var delegate: SideMenuDelegate?
        var viewModel: (any ProblemViewModelProtocol)?
    }
    
    var viewModel: (any ProblemViewModelProtocol)?
    
    static func create(with dependencies: Dependencies) -> Self{
        let code = CodeProblemViewController()
        code.viewModel = dependencies.viewModel
        return code as! Self
    }
    
    lazy var problemTableView: RefreshTableView = {
        let tableView = RefreshTableView(frame: .zero, style: .plain)
        tableView.register(ProblemCell.self, forCellReuseIdentifier: ProblemCell.identifier)
        tableView.estimatedRowHeight = 200
        tableView.separatorColor = UIColor.clear
        tableView.rowHeight = UITableView.automaticDimension
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
        for index in 0...titles.count-1 {
            segmentControl.setWidth(50, forSegmentAt: index)
        }
        return segmentControl
    }()
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindingModel()
        
        _viewDidLoad.accept(())
        
        layoutConfigure()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        _viewDissapear.accept(())
        
        if self.navigationController == nil{
            disposeBag = DisposeBag()
        }
    }
    
    
    //MARK: - View Layout Configure
    private func layoutConfigure(){
        self.view.backgroundColor = UIColor.systemBackground
        self.title = "Problem List"
        self.view.addSubview(problemTableView)
        problemTableView.snp.makeConstraints{
            $0.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges)
        }
        settingSegmentControll()
    }
    
    
    //MARK: - Binding from ViewModel
    var disposeBag: DisposeBag = DisposeBag()
    var _viewDidLoad = PublishRelay<Void>()
    var _viewDissapear = PublishRelay<Void>()
    var _foldButtonSeleted = PublishRelay<(Int,Bool)>()
    var _cellSelect = PublishRelay<Void>()
    
    var _fetchProblemList = PublishRelay<Void>()
        
    lazy var _segmentcontrolValue = segmentControl.rx.selectedSegmentIndex.asSignal(onErrorJustReturn: 0)
    
    lazy var input = CodeProblemViewModel.Input(viewDidLoad: _viewDidLoad.asSignal(),
                                                viewDissapear: _viewDissapear.asSignal(),
                                                segmentIndex: _segmentcontrolValue,
                                                foldButtonSeleted: _foldButtonSeleted.asSignal(),
                                                cellSelect: _cellSelect.asSignal(),
                                                fetchProblemList: _fetchProblemList.asSignal())
    
    var output: CodeProblemViewModel.Output?
    
    #if DEBUG
    func cellClickedEvent(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: { [weak self] in
            guard let self else {return}
            self._cellSelect.accept(())
        })
    }
    #endif
    
    private func bindingModel(){
        let viewmodel = (viewModel as? CodeProblemViewModel)
        self.output = viewmodel?.transform(input)
        
        let scroll = problemTableView.rx.didScroll.asDriver()
        let dragging =  problemTableView.rx.didEndDragging.asDriver()
        
        
        output?.refreshEndEvnet
            .drive(with: self,onNext: { vc, _ in
                vc.removeBottomRefresh()
            }).disposed(by: disposeBag)
        
        dragging
            .drive(with: self,onNext: { vc, value in
                let table = vc.problemTableView
                guard let vm = vc.viewModel else { return }
                if table.contentOffset.y > table.contentSize.height - table.bounds.height,
                   vm.isLoading{
                    vc.addBottomRefresh()
                }
            }).disposed(by: disposeBag)
        
        
        scroll
            .filter{[weak self] _ in
                guard let self,
                      let vm = self.viewModel
                else {return false}
               return vm.isLoading ? false : true
            }
            .drive(with: self,onNext: { vc , _ in
                let table = vc.problemTableView
                if table.contentOffset.y > table.contentSize.height - table.bounds.height{
                    vc.viewModel?.isLoading = true
                    vc._fetchProblemList.accept(())
                }
            }).disposed(by: disposeBag)

        
        problemTableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        guard let seg_list_model = self.output?.seg_list_model.asObservable() else {return}
        
        
        seg_list_model.bind(to: problemTableView.rx.items(cellIdentifier: ProblemCell.identifier,cellType: ProblemCell.self))
        {
            (index: Int, model : DummyModel ,cell: ProblemCell) in
        
            cell.binder.onNext(model)
            
            let isSelected = cell.foldButton.isSelected
            
            cell.foldButtonTap?.asObservable().bind(onNext: { [weak self] in
                guard let self = self else {return}
                self._foldButtonSeleted.accept((index,isSelected))
            }).disposed(by: cell.disposeBag)

            cell.problemCell_tapGesture?.rx.event
                .asSignal()
                .emit(onNext: { [weak self] _ in
                    self?._cellSelect.accept(())
                }).disposed(by: cell.disposeBag)
            
        }.disposed(by: disposeBag)
            
    }
    
    
    
    fileprivate var animationDuration: Double = 0.2
    
    fileprivate var bottomView = CustomBottomView()
    
    private func addBottomRefresh(){
        self.bottomView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
        self.problemTableView.tableFooterView = bottomView
        
        UIView.animate(withDuration: animationDuration) {
            self.problemTableView.contentInset.bottom = 50
        }
    }
    
    private func removeBottomRefresh(){
        DispatchQueue.main.async { [weak self] in
            if let self = self{
                UIView.animate(withDuration: self.animationDuration) {
                    self.problemTableView.tableFooterView = nil
                }
            }
        }
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
    
    func settingSegmentControll(){
        segmentControl.sizeToFit()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: segmentControl)
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl){
//        sender.selectedSegmentIndex
    }
}