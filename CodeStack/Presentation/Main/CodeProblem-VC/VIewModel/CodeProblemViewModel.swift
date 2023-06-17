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
        var viewDissapear: Signal<Void>
        var segmentIndex: Signal<Int>
        var foldButtonSeleted: Signal<(Int,Bool)>
        var cellSelect: Signal<Void>
    }
    
    struct Output{
        var seg_list_model: Driver<[DummyModel]>
        var cell_temporary_content_update: Driver<(Int,Bool)>
    }
    
    private var service: DummyData
    
    init(_ service: DummyData){
        self.service = service
    }
    
    deinit{
        print("\(String(describing: Self.self)) - deinint")
    }
    
    //Output
    private var seg_list_model = PublishRelay<[DummyModel]>()
    
    //handler
    private var listModel = PublishRelay<[DummyModel]>()
    private var segmentIndex = BehaviorSubject<Int>(value: 0)
    private var foldButton = PublishSubject<(Int,Bool)>()
    
    var disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output{
        
        _ = input.viewDidLoad
            .withUnretained(self)
            .emit(onNext: { vm,_ in
                let model = vm.service.getAllModels()
                vm.listModel.accept(model)
            })
            .disposed(by: disposeBag)
        
        //추후에 flow 분리후 추가예정
        //        _ = input.viewDissapear
        //            .map{ _ in CodestackStep.problemComplete}
        //            .emit(to: steps)
        _ = input.cellSelect
            .map{_ in CodestackStep.problemPick("")}
            .emit(to: steps)
            .disposed(by: disposeBag)
        
        _ = input.segmentIndex
            .emit(to: segmentIndex)
            .disposed(by: disposeBag)
        
        _ = input.foldButtonSeleted
            .withUnretained(self)
            .emit(onNext: { vm, model in
                vm.foldButton.onNext(model)
            })
            .disposed(by: disposeBag)
        
        
        foldButton
            .withLatestFrom(seg_list_model){data, originals in
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
