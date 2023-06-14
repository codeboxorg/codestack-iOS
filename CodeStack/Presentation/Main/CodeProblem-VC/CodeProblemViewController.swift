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


class CodeProblemViewController: UIViewController, UITableViewDelegate{
    
    struct Dependencies{
//        var delegate: SideMenuDelegate?
        var viewModel: (any ProblemViewModelProtocol)?
    }
    
//    weak var delegate: SideMenuDelegate?
    var viewModel: (any ProblemViewModelProtocol)?
    
    static func create(with dependencies: Dependencies) -> Self{
        let code = CodeProblemViewController()
//        code.delegate = dependencies.delegate
        code.viewModel = dependencies.viewModel
        return code as! Self
    }
    
    lazy var problemTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
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
        //moveFunc()
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
    var foldButtonSeleted = PublishRelay<(Int,Bool)>()
    
    lazy var _segmentcontrolValue = segmentControl.rx.selectedSegmentIndex.asSignal(onErrorJustReturn: 0)
    lazy var input = CodeProblemViewModel.Input(viewDidLoad: _viewDidLoad.asSignal(),
                                                segmentIndex: _segmentcontrolValue,
                                                foldButtonSeleted: foldButtonSeleted.asSignal())
    
    var output: CodeProblemViewModel.Output?
    
    
    private func bindingModel(){
        let viewmodel = (viewModel as? CodeProblemViewModel)
        self.output = viewmodel?.transform(input)
        
        problemTableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        problemTableView.rx
            .modelSelected(DummyModel.self)
            .withUnretained(self)
            .subscribe(onNext: { vc,k in
                print("cell tapped")
            }).disposed(by: disposeBag)
        
        guard let seg_list_model = self.output?.seg_list_model.asObservable() else {return}
        
        seg_list_model.bind(to: problemTableView.rx.items(cellIdentifier: ProblemCell.identifier))
        {
            (index: Int, model : DummyModel ,cell: ProblemCell) in
            
            cell.binder.onNext(model)
            
            cell.foldButtonTap.bind(onNext: {
                self.foldButtonSeleted.accept((index,cell.foldView.isSelected))
            }).disposed(by: cell.disposeBag)
            
            cell.problemCell_tapGesture?
                .asSignal()
                .emit(onNext: { recognizer in
                    let editorvc = CodeEditorViewController()
                    self.navigationController?.pushViewController(editorvc, animated: true)
                }).disposed(by: cell.disposeBag)
            
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
    
    func settingSegmentControll(){
        segmentControl.sizeToFit()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: segmentControl)
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl){
        sender.selectedSegmentIndex
    }
}

