//
//  CodeProblemViewModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/05/03.
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

protocol ProblemViewModelProtocol{
    associatedtype Input = CodeProblemViewModel.Input
    associatedtype Output = CodeProblemViewModel.Output
    
    func transform(_ input: Input) -> Output
}

class CodeProblemViewModel: ProblemViewModelProtocol,Stepper{
    var steps = PublishRelay<Step>()
    
    struct Input{
        var viewDidLoad: Signal<Void>
        var segmentIndex: Signal<Int>
        var foldButtonSeleted: Signal<(Int,Bool)>
    }
    
    struct Output{
        var seg_list_model: Driver<[DummyModel]>
        var cell_temporary_content_update: Driver<(Int,Bool)>
    }
    
    private var service: DummyData
    
    init(_ service: DummyData){
        self.service = service
    }
    
    //Output
    private var seg_list_model = PublishRelay<[DummyModel]>()
    
    //handler
    private var listModel = PublishRelay<[DummyModel]>()
    private var segmentIndex = BehaviorSubject<Int>(value: 0)
    private var foldButton = PublishSubject<(Int,Bool)>()
    
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
        

        foldButton
            .withLatestFrom(seg_list_model){ data, originals in
                let (index, flag) = data
                var origin = originals
                origin[index].flag = !flag
                return origin
            }
            .bind(to: seg_list_model)
            .disposed(by: disposeBag)
        
        
        Observable.combineLatest(listModel, segmentIndex, resultSelector: { model, index  in
            let flag = index == 0 ? true : false
            return model.map{ problem, lang, _ in DummyModel(model: problem,language: lang, flag: flag )}
        })
        .bind(to: seg_list_model)
        .disposed(by: disposeBag)
        
        
        
        return Output(seg_list_model: seg_list_model.asDriver(onErrorJustReturn: []),
                      cell_temporary_content_update: foldButton.asDriver(onErrorJustReturn: (0,false)))
    }
    
}
