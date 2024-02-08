//
//  HistoryViewModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/18.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import Swinject
import Global
import Domain
import RxFlow

protocol HistoryViewModelType: ViewModelType, AnyObject {
    var sendSubmission: PublishRelay<SubmissionVO> { get set }
    var deleteSubmission: PublishRelay<SubmissionVO> { get set }
}

class HistoryViewModel: HistoryViewModelType {
    
    struct Input{
        var viewDidLoad: Signal<Void>
        var currentSegment: Driver<SegType.Value>
        var refreshTap: Signal<Void>
        var fetchHistoryList: Signal<Void>
        var paginationLoadingInput: Signal<Bool>
        var deleteHistory: Signal<Int>
        var logout: Signal<Void>
    }
    
    struct Output{
        var historyData: Driver<[SubmissionVO]>
        var paginationRefreshEndEvent: Signal<Void>
        var paginationLoading: Driver<Bool>
        var refreshClearEvent: Signal<Void>
        var historyIsEmpty: BehaviorRelay<Bool>
    }
    
    struct Dependency {
        let submisionUsecase: HistoryUsecase
        let homeViewModel: any HomeViewModelType
        let container: Container
    }
    
    private let historyUsecase: HistoryUsecase
    private var submissionUseCase: SubmissionUseCase?
    private weak var container: Container?
    private weak var homeViewmodel: (any HomeViewModelType)?
    
    init(dependency: Dependency){
        self.historyUsecase = dependency.submisionUsecase
        self.homeViewmodel = dependency.homeViewModel
        self.container = dependency.container
        observingSubmission()
        observingDeleteSubmission()
    }
    
    private var disposeBag = DisposeBag()
    
    private let submissionModel = BehaviorRelay<[SubmissionVO]>(value: (0...6).map { _ in SubmissionVO.mock })
    private let historyData = BehaviorRelay<[SubmissionVO]>(value: [])
    private var historyIsEmpty = BehaviorRelay<Bool>(value: true)
    private let paginationLoadingInput = BehaviorRelay<Bool>(value: false)
    
    //Bottom Pagination refresh
    private let refreshEndEvent = PublishRelay<Void>()
    
    //Navigation Top right refresh
    private let refreshClearEvent = PublishRelay<Void>()
    
    private var initialLoad: Bool = true
    private var initialViewDidLoad = BehaviorRelay<Bool>(value: true)
    
    
    private var currentPage: CurrentPage = 0 {
        didSet {
            Log.debug("currentPage: \(self.currentPage)")
        }
    }
    
    private var totalPage: Int = 50
    
    var sendSubmission = PublishRelay<SubmissionVO>()
    var deleteSubmission = PublishRelay<SubmissionVO>()
    var steps = PublishRelay<Step>()
    
    deinit { Log.debug("historyViewmodel deinit") }
    
    /// Delegate Mapping Add Submission
    private func observingSubmission() {
        sendSubmission
            .withLatestFrom(historyData){ value, original in
                // 최근 기록이 추가되는 것이므로 새로운 value는 앞에 추가가 되어야 합니다
                return [value] + original
            }
            .subscribe(with: self, onNext: { vm, value in
                 vm.historyData.accept(value)
            }).disposed(by: disposeBag)
    }
    
    
    /// Delegate Mapping Delete Submission
    private func observingDeleteSubmission() {
        deleteSubmission
            .withLatestFrom(historyData) { receive, original in
                original.deleteEqualStatusCodes(receive: receive)
            }
            .bind(to: historyData)
            .disposed(by: disposeBag)
    }
    
    func transform(input: Input) -> Output {
        
        input.paginationLoadingInput
            .emit(to: paginationLoadingInput)
            .disposed(by: disposeBag)
        
        //TODO: - Refresh Button을 어떻게 구성할지
        refreshBinding(tap: input.refreshTap)
        viewDidLoadBinding(viewDidLoad: input.viewDidLoad)
        fetchHistoryBinding(fetchHistory: input.fetchHistoryList)
        
        bindingHistoryLists()
        
        // TODO: 현재 Filter해서 fetch 해오는 Query 부재 -> 기능 추후 제공
        let filteredHistoryData = filteredHistoryList(segment: input.currentSegment)
        deleteHistoryItem(input: input.deleteHistory, list: filteredHistoryData )
        
        input.logout
            .emit(with: self, onNext: { vm, _ in
                vm.container?.resetObjectScope(.history)
            }).disposed(by: disposeBag)
            
        
        return Output(historyData: filteredHistoryData,
                      paginationRefreshEndEvent: refreshEndEvent.asSignal(),
                      paginationLoading: paginationLoadingInput.asDriver(onErrorJustReturn: false),
                      refreshClearEvent: refreshClearEvent.asSignal(),
                      historyIsEmpty: historyIsEmpty)
    }
    
    private func deleteHistoryItem(input deleteHistory: Signal<Int>, list filtered: Driver<[SubmissionVO]>) {
        
        let findDeleteSub = deleteHistory
            .asObservable()
            .withUnretained(self)
            .flatMap { vm, index -> Observable<(Int, [SubmissionVO])> in
                let index: Observable<Int> = .just(index)
                let data: Observable<[SubmissionVO]> = filtered.asObservable().take(1)
                return Observable.zip(index, data)
            }
            .map { index, subList in
                let deletedSubVo = subList[index]
                return (deletedSubVo)
            }
        
        findDeleteSub
            .withUnretained(self)
            .flatMap { vm, deleteVO in
                // TODO: View에 반영 해야함 -> Home ViewModel ,, favorite 일때는 필요없음
                vm.historyUsecase.deleteItem(item: deleteVO)
                    .do(onCompleted: { vm.homeViewmodel?.deleteSubmission.accept(deleteVO) })
                    .andThen(Observable.just(deleteVO))
            }
            .bind(to: deleteSubmission)
            .disposed(by: disposeBag)
    }
    
    func filteredHistoryList(segment: Driver<SegType.Value>) -> Driver<[SubmissionVO]> {
        Driver<[SubmissionVO]>
            .combineLatest(historyData.asDriver(), segment)
        { submissions, segment in
            submissions.filter { $0.statusCode.checkIsEqual(with: segment) }
        }.do(onNext: { [weak self] filteredSubVos in
            self?.historyIsEmpty.accept(filteredSubVos.isEmpty)
        })
    }
    
    func bindingHistoryLists() {
        let historyWithLatestForm =
        submissionModel
            .withLatestFrom(historyData) { submission, original in
                return original + submission
            }
        
        historyWithLatestForm
            .skip(2)
            .bind(to: historyData)
            .disposed(by: disposeBag)
        
        Observable.zip(submissionModel, initialViewDidLoad)
            .take(2)
            .map { tuple in
                let (submission, loading) = tuple
                if loading == true {
                    return submission
                } else {
                    return submission.filter(\.isNotMock)
                }
            }
            .bind(to: historyData)
            .disposed(by: disposeBag)
    }
    
    func viewDidLoadBinding(viewDidLoad: Signal<Void>){
        viewDidLoad
            .withUnretained(self)
            .flatMap { vm, _ in
                vm.fetchSubmissionHistory()
                .asSignal(onErrorJustReturn: []) }
            .delay(.milliseconds(800))
            .do(onNext: { [weak self] _ in self?.initialViewDidLoad.accept(false) })
            .emit(to: submissionModel)
            .disposed(by: disposeBag)
        
        viewDidLoad
            .emit(to: refreshEndEvent)
            .disposed(by: disposeBag)
        
        viewDidLoad
            .map { _ in false }
            .emit(to: paginationLoadingInput)
            .disposed(by: disposeBag)
    }
    
    func fetchHistoryBinding(fetchHistory list: Signal<Void>) {
        let isOverFage = list.withUnretained(self)
            .filter { vm, _ in
                if vm.currentPage >= vm.totalPage {
                    vm.paginationLoadingInput.accept(false)
                    vm.refreshEndEvent.accept(())
                    return false
                }
                return true
            }
        
        isOverFage
            .delay(.milliseconds(200))
            .flatMap {vm, _ in
                vm.historyUsecase.fetchSubmission(offset: vm.currentPage).asSignal(onErrorJustReturn: [])
            }
            .asObservable()
            .do(onNext: { [weak self] datas in
                if !datas.isEmpty { self?.currentPage += 1 }
                // TODO: Fall Back UI Present 필요
                self?.refreshEndEvent.accept(())
                self?.paginationLoadingInput.accept(false)
            })
            .filter { $0.isEmpty }
            .bind(to: submissionModel)
            .disposed(by: disposeBag)
    }
    
    func refreshBinding(tap: Signal<Void>){
        tap
            .throttle(.milliseconds(800))
            .asObservable()
            .withUnretained(self)
            .flatMapLatest { vm, _ in vm.historyUsecase.fetchSubmission(offset: 0) }
            .subscribe(with: self, onNext: { vm, datas in
                vm.submissionModel.accept(datas)
                vm.refreshEndEvent.accept(())
                vm.paginationLoadingInput.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchSubmissionHistory() -> Observable<[SubmissionVO]> {
        let favoriteProblems =
        historyUsecase
            .fetchFavoriteProblem()
            .compactMap { try $0.get() }
            .map { $0.map { favVO in favVO.toSubmissionVO() } }
        
        let localTempSubmission =
        historyUsecase
            .fetchProblemHistoryEqualStatus(status: "temp")
            .compactMap { try $0.get() }
        
        let fetchedSubmission =
        historyUsecase
            .fetchSubmission(offset: self.currentPage)
            .do(onNext: { [weak self] _ in self?.currentPage += 1 })
    
        return Observable<[SubmissionVO]>
            .zip(favoriteProblems, localTempSubmission, fetchedSubmission) {
                return ($0 + $1 + $2).sortByDate()
            }
    }
    
    private lazy var retryHandler: (Observable<Error>) -> Observable<Int> = { error in
        error.enumerated().flatMap { [weak self] (attempt, error) -> Observable<Int> in
            if attempt >= 3 {
                return Observable.error(error)
            }
            self?.currentPage += 1
            return Observable<Int>.timer(.milliseconds(300), scheduler: MainScheduler.instance).take(1)
        }
    }
    
    // TODO: - "INTERNAL_SERVER_ERROR",
    // 현재 getMe 의 submission query Internal Server Error 발생
    private func requestGetMeSubmissions(){
        // _ = service.getMeSubmissions(query: Query.getMeSubmissions())
    }
    
    private func requestMe(){
        // TODO: - 현재 SolvedProblem만 가지고 온다.
        // 에러나 성공 실패 했을때의 결과에 대한 Submission을 가지고 오기 위해서는
        // Submission에 조건을 달아서 query를 날려야 되나
    }
}
