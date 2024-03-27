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

protocol ProblemViewModelProtocol {
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
        var cellSelect: Signal<AnimateProblemModel>
        var fetchProblemList: Signal<Void>
    }
    
    struct Output {
        var seg_list_model: Driver<[AnimateProblemModel]>
        var cell_temporary_content_update: Driver<(Int,Bool)>
        var refreshEndEvnet: Driver<Void>
    }
    
    init(_ problem: AnimateProblemModel, _ service: ProblemUsecase){
        self.problemModel = problem
        self.useCase = service
    }
    
    deinit { print("\(String(describing: Self.self)) - deinint") }
    
    private var problemModel: AnimateProblemModel
    private var useCase: ProblemUsecase
    internal var animationSelected: [String : Bool] = [:]
    
    //Output
    private var seg_list_model = PublishRelay<[AnimateProblemModel]>()
    
    //handler
    private var listModel = PublishRelay<[AnimateProblemModel]>()
    private var segmentIndex = BehaviorSubject<Int>(value: 0)
    private var foldButton = PublishSubject<(Int,Bool)>()
    private var refreshEnd = PublishRelay<Void>()
    private var fetchListModels = PublishRelay<[AnimateProblemModel]>()
    var isLoading: Bool = false
    private var currentPage: CurrentPage = 0
    private var totalPage: Int = 10
    var disposeBag = DisposeBag()
    
    func transform(_ input: Input) -> Output {
        
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
                guard let self else { return [] }
                let flag = index == 0 ? true : false
                let model: [AnimateProblemModel] = model.map
                { animate in
                    self.animationSelected[animate.problemVO.id] = flag
                    return AnimateProblemModel(problemVO: animate.problemVO, flag: flag)
                }
                return model
            })
            .bind(to: seg_list_model)
            .disposed(by: disposeBag)
        
        fetchWhenPagination(input: input.fetchProblemList)
        
        fetchWhenViewDidLoad(load: input.viewDidLoad)
        
        viewActionBinding(input: input)
        
        return Output(seg_list_model: seg_list_model.asDriver(onErrorJustReturn: []),
                      cell_temporary_content_update: foldButton.asDriver(onErrorJustReturn: (0,false)),
                      refreshEndEvnet: refreshEnd.asDriver(onErrorJustReturn: ()))
    }
    
    private func viewActionBinding(input: Input) {
        //MARK: - Cell Select
        _ = input.cellSelect
            .withUnretained(self)
            .flatMapFirst { vm, animateModel in Signal.just(animateModel) }
            .map { ProblemSolveEditor(problemVO: $0.problemVO, submissionVO: nil)}
            .map{ editor in CodestackStep.problemPick(editor) }
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
                // Data fetch 실패시 기본 default 값 fetch
                vm.modelUpdate(problems, model: vm.fetchListModels)
                vm.currentPage += 1
                vm.isLoading = false
                vm.refreshEnd.accept(())
            }).disposed(by: disposeBag)
    }
    
    
    private func fetchWhenViewDidLoad(load: Signal<Void>) {
        
        let fetchFB = useCase.fetchProblemList()
        
        let fetchGraph =
        useCase.fetchProblems(offset: currentPage)
            .do(onNext: { [weak self] pageInfo in self?.totalPage = pageInfo.pageInfo.limit },
                onError: { err in Log.debug("err: \(err)") })
            .map { $0.probleminfoList }
            .asSignal(onErrorJustReturn: [])
        
        load.withUnretained(self)
            .flatMap { _ in fetchFB.asSignal(onErrorJustReturn: []) }
            .map { $0.map { problem in AnimateProblemModel(problemVO: problem, flag: false) } }
            .emit(to: listModel)
            .disposed(by: disposeBag)
        
        _ = load
            .withUnretained(self)
            .flatMap { vm, _ in
                vm.isLoading = true
                return fetchGraph
            }
            .emit(with: self, onNext: { vm, problems in
                vm.modelUpdate(problems, model: vm.listModel)
                vm.currentPage += 1
                vm.isLoading = false
                vm.refreshEnd.accept(())
            })
            .disposed(by: disposeBag)
    }
    
    private func modelUpdate(_ problems: [ProblemVO], model: PublishRelay<[AnimateProblemModel]>) {
        if problems.isEmpty {
            let tempModel = problemModel.getAllModels(index: currentPage)
            tempModel.forEach { model in
                animationSelected[model.problemVO.id] = model.flag
            }
            model.accept(tempModel)
        } else {
            let animateProblemModel = problems.map { problem in
                return AnimateProblemModel(problemVO: problem, flag: false)
            }
            animateProblemModel.forEach { model in
                animationSelected[model.problemVO.id] = model.flag
            }
            model.accept(animateProblemModel)
        }
    }
}
