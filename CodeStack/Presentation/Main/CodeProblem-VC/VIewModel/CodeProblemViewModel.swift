//
//  CodeProblemViewModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/05/03.
//

import Foundation
import RxSwift
import RxCocoa

protocol ProblemViewModelProtocol{
    associatedtype Input = CodeProblemViewModel.Input
    associatedtype Output = CodeProblemViewModel.Output
    
    func transform(_ input: Input) -> Output
}

class CodeProblemViewModel: ProblemViewModelProtocol{
    
    struct Input{
        var viewDidLoad: Signal<Void>
        var segmentIndex: Signal<Int>
        var foldButtonSeleted: Signal<Bool>
    }
    
    struct Output{
        var seg_list_model: Driver<[DummyModel]>
    }
    
    private var service: DummyData
    
    init(_ service: DummyData = DummyData()){
        self.service = service
    }
    
    private var seg_list_model = PublishRelay<[DummyModel]>()
    
    private var listModel = PublishRelay<[DummyModel]>()
    private var segmentIndex = BehaviorSubject<Int>(value: 0)
    private var foldButton = BehaviorSubject<Bool>(value: true)
    
    var disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output{
        input.viewDidLoad
            .withUnretained(self)
            .emit(onNext: { vm,_ in
                let model = vm.service.getAllModels()
                vm.listModel.accept(model)
            })
            .disposed(by: disposeBag)
        
        input.segmentIndex
            .emit(to: segmentIndex)
            .disposed(by: disposeBag)
        
        input.foldButtonSeleted
            .emit(to: foldButton)
            .disposed(by: disposeBag)
        
        
        Observable.combineLatest(listModel, segmentIndex, resultSelector: { model, index  in
            let flag = index == 0 ? true : false
            return model.map{ problem, lang, _ in DummyModel(model: problem,language: lang, flag: flag )}
        })
        .bind(to: seg_list_model)
        .disposed(by: disposeBag)
            
        
        
        return Output(seg_list_model: seg_list_model.asDriver(onErrorJustReturn: []))
    }
    
}
