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
    
    var isLoading: Bool { get set }
    
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
        var fetchProblemList: Signal<Void>
    }
    
    struct Output{
        var seg_list_model: Driver<[DummyModel]>
        var cell_temporary_content_update: Driver<(Int,Bool)>
        var refreshEndEvnet: Driver<Void>
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
    
    
    private var refreshEnd = PublishRelay<Void>()
    private var fetchListModels = PublishRelay<[DummyModel]>()
    
    var isLoading: Bool = false
    
    private var currentPage: CurrentPage = 0
    private var totalPage: Int = 10
    
    var disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output{
        
        
        //fetch logic
        _ = input.fetchProblemList
            .withUnretained(self)
            .filter{ vm,_ in
                if vm.currentPage >= vm.totalPage{
                    vm.isLoading = false
                    vm.refreshEnd.accept(())
                    return false
                }
                return true
            }
            .delay(.seconds(1))
            .emit(with: self, onNext: { vm, value in
                let model = vm.service.fetchModels(currentPage: vm.currentPage)
                vm.currentPage += 1
                vm.fetchListModels.accept(model)
                vm.isLoading = false
                vm.refreshEnd.accept(())
            }).disposed(by: disposeBag)
        
        
        _ = input.viewDidLoad
            .withUnretained(self)
            .emit(onNext: { vm,_ in
                let model = vm.service.getAllModels()
                vm.currentPage += 1
                vm.listModel.accept(model)
            })
            .disposed(by: disposeBag)
        
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
        
        
        fetchListModels
            .withLatestFrom(listModel){ model, originals in
                return originals + model
            }.bind(to: listModel)
            .disposed(by: disposeBag)
        
        
        Observable.combineLatest(listModel, segmentIndex, resultSelector: { model, index  in
            let flag = index == 0 ? true : false
            return model.map{ problem, lang, _ in DummyModel(model: problem,language: lang, flag: flag )}
        })
        .bind(to: seg_list_model)
        .disposed(by: disposeBag)
        
        
        return Output(seg_list_model: seg_list_model.asDriver(onErrorJustReturn: []),
                      cell_temporary_content_update: foldButton.asDriver(onErrorJustReturn: (0,false)),
                      refreshEndEvnet: refreshEnd.asDriver(onErrorJustReturn: ()))
    }
}
