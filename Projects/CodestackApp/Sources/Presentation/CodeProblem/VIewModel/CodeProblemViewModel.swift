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
import Domain
import Global

protocol ProblemViewModelProtocol{
    associatedtype Input = CodeProblemViewModel.Input
    associatedtype Output = CodeProblemViewModel.Output
    
    var isLoading: Bool { get set }
    var animationSelected: [String : Bool] { get set }
    func transform(_ input: Input) -> Output
}

class CodeProblemViewModel: ProblemViewModelProtocol,Stepper {
    
    var steps = PublishRelay<Step>()
    
    struct Input {
        var viewDidLoad: Signal<Void>
        var deinitVC: Signal<Void>
        var segmentIndex: Signal<Int>
        var foldButtonSeleted: Signal<(Int,Bool)>
        var cellSelect: Signal<DummyModel>
        var fetchProblemList: Signal<Void>
    }
    
    struct Output {
        var seg_list_model: Driver<[DummyModel]>
        var cell_temporary_content_update: Driver<(Int,Bool)>
        var refreshEndEvnet: Driver<Void>
    }
    
    private var dummy: DummyData
    
    private var useCase: ProblemUsecase
    
    var animationSelected: [String : Bool] = [:]
    
    init(_ dummy: DummyData, _ service: ProblemUsecase){
        self.dummy = dummy
        self.useCase = service
    }
    
    deinit { print("\(String(describing: Self.self)) - deinint") }
    
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
        fetchWhenPagination(input: input.fetchProblemList)
        
        fetchWhenViewDidLoad(load: input.viewDidLoad)
        
        //MARK: View Will Disappear
        // _ = input.deinitVC
        //     .emit(with: self, onNext: { vm , value in
        //     }).disposed(by: disposeBag)
        
        //MARK: - Cell Select
        _ = input.cellSelect
            .withUnretained(self)
            .flatMapFirst { vm, model in
                return Signal.just(model)
            }
            .map{ model in CodestackStep.problemPick(model.model) }
            .emit(to: steps)
            .disposed(by: disposeBag)
        
        //MARK: - Segment action = Index ? strech OR Fold (all presented Problem Cell)
        _ = input.segmentIndex
            .map { $0 }
            .emit(to: segmentIndex)
            .disposed(by: disposeBag)
        
        
        //MARK: - Problem Cell Fold Button
        _ = input.foldButtonSeleted
            .withUnretained(self)
            .emit(onNext: { vm, model in
                vm.foldButton.onNext(model)
            })
            .disposed(by: disposeBag)
        
        //MARK: - Problem Cell Fold Button
        foldButton
            .withLatestFrom(seg_list_model){data, originals in
                let (index, flag) = data
                var origin = originals
                origin[index].flag = !flag
                return origin
            }
            .bind(to: seg_list_model)
            .disposed(by: disposeBag)
        
        
        //MARK: - Add Fetched Data -> to listModel
        fetchListModels
            .withLatestFrom(listModel){ model, originals in
                return originals + model
            }.bind(to: listModel)
            .disposed(by: disposeBag)
        
        
        //MARK: CombinLatest (list,seg)
        Observable
            .combineLatest(listModel, segmentIndex, resultSelector: { [weak self] model, index  in
                guard let self else {return .init()}
            let flag = index == 0 ? true : false
            let model = model.map
            { problem, lang, _ in
                self.animationSelected[problem.problemNumber] = flag
                return DummyModel(model: problem,language: lang, flag: flag )
            }
            return model
        })
        .bind(to: seg_list_model)
        .disposed(by: disposeBag)
        
        return Output(seg_list_model: seg_list_model.asDriver(onErrorJustReturn: []),
                      cell_temporary_content_update: foldButton.asDriver(onErrorJustReturn: (0,false)),
                      refreshEndEvnet: refreshEnd.asDriver(onErrorJustReturn: ()))
    }
    
    
    private func fetchWhenPagination(input list: Signal<Void>) {
        //fetch logic
        _ = list
            .withUnretained(self)
            .filter { vm,_ in
                if vm.currentPage >= vm.totalPage {
                    vm.isLoading = false
                    vm.refreshEnd.accept(())
                    return false
                }
                return true
            }
            .flatMap { vm, _ in
                vm.useCase.fetchProblems(offset: vm.currentPage)
                    .map { $0.probleminfoList }
                    .asSignal(onErrorJustReturn: [])
            }
            .emit(with: self, onNext: { vm, problems in
                let dummyModel = problems.map { problem in
                    let list = problem.toProblemList()
                    return (model: list,language: problem.languages, flag: false)
                }
                vm.currentPage += 1
                vm.isLoading = false
                vm.refreshEnd.accept(())
                
                // Data fetch 실패시 기본 default 값 fetch
                if dummyModel.isEmpty {
                    let tempModel = vm.dummy.getAllModels(index: vm.currentPage)
                    tempModel.forEach { model in
                        vm.animationSelected[model.model.problemNumber] = model.flag
                    }
                    vm.fetchListModels.accept(tempModel)
                } else {
                    dummyModel.forEach { model in
                        vm.animationSelected[model.model.problemNumber] = model.flag
                    }
                    vm.fetchListModels.accept(dummyModel)
                }
            }).disposed(by: disposeBag)
    }
    
    
    private func fetchWhenViewDidLoad(load: Signal<Void>) {
        _ = load
            .withUnretained(self)
            .flatMap { vm, _ in
                vm.isLoading = true
                return vm.useCase.fetchProblems(offset: vm.currentPage)
                    .do(onNext: { pageInfo in vm.totalPage = pageInfo.pageInfo.limit },
                        onError: { err in Log.debug("err: \(err)") })
                    .map { $0.probleminfoList }
                    .asSignal(onErrorJustReturn: [])
            }
            .emit(with: self, onNext: { vm, problems in
                if problems.isEmpty {
                    let tempModel = vm.dummy.getAllModels(index: vm.currentPage)
                    tempModel.forEach { model in
                        vm.animationSelected[model.model.problemNumber] = model.flag
                    }
                    vm.listModel.accept(tempModel)
                } else {
                    let dummyModel = problems.map { problem in
                        let list = problem.toProblemList()
                        return (model: list,language: problem.languages, flag: false)
                    }
                    dummyModel.forEach { model in
                        vm.animationSelected[model.model.problemNumber] = model.flag
                    }
                    vm.listModel.accept(dummyModel)
                }
                vm.currentPage += 1
                vm.isLoading = false
                vm.refreshEnd.accept(())
            })
            .disposed(by: disposeBag)
    }
    
//    private func requestProblem(offset: Int,
//                                sort: String = "id",
//                                order: String = "asc") -> Signal<[ProblemVO]> {
//        apollo
//            // .getProblemsQuery(query: Query.getProblems(offset: offset, sort: sort, order: order))
//        //TODO: 확인후 변경
//            .getProblemsQuery(.PR_LIST(arg: GRAR(offset: offset)))
//            .map { $0.0 }
////            .map { frInfo in
////                frInfo.0.map { fr in fr.toDomain() }
////            }
//            .asSignal(onErrorJustReturn: [])
//    }
}
