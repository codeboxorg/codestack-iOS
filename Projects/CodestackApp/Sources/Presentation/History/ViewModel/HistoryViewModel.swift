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
import Global
import Domain

protocol HistoryViewModelType: ViewModelType, AnyObject {
    var sendSubmission: PublishRelay<SubmissionVO> { get set }
}

class HistoryViewModel: HistoryViewModelType {
    
    struct Input{
        var viewDidLoad: Signal<Void>
        var currentSegment: Driver<SegType.Value>
        var refreshTap: Signal<Void>
        var fetchHistoryList: Signal<Void>
        var paginationLoadingInput: Signal<Bool>
        var deleteHistory: Signal<Int>
    }
    
    struct Output{
        var historyData: Driver<[SubmissionVO]>
        var paginationRefreshEndEvent: Signal<Void>
        var paginationLoading: Driver<Bool>
        var refreshClearEvent: Signal<Void>
    }
    
    
    struct Dependency {
        let submisionUsecase: HistoryUsecase
    }
    private let historyUsecase: HistoryUsecase
    
    init(dependency: Dependency){
        self.historyUsecase = dependency.submisionUsecase
    }
    
    private var disposeBag = DisposeBag()
    private let submissionModel = BehaviorRelay<[SubmissionVO]>(value: [])
    private let historyData = BehaviorRelay<[SubmissionVO]>(value: [])
    
    
    // private let favoriteModel
    private let paginationLoading = BehaviorRelay<Bool>(value: false)
    
    
    private var currentPage: CurrentPage = 0 {
        didSet {
            Log.debug("currentPage: \(self.currentPage)")
        }
    }
    private var totalPage: Int = 50
    
    //Bottom Pagination refresh
    private let refreshEndEvent = PublishRelay<Void>()
    
    //Navigation Top right refresh
    private let refreshClearEvent = PublishRelay<Void>()
    
    var sendSubmission = PublishRelay<SubmissionVO>()
    
    func transform(input: Input) -> Output {
        
        input.paginationLoadingInput
            .emit(to: paginationLoading)
            .disposed(by: disposeBag)
        
        observingSubmission()
        
        //TODO: - Refresh Button을 어떻게 구성할지
        refreshBinding(tap: input.refreshTap)
        viewDidLoadBinding(viewDidLoad: input.viewDidLoad)
        fetchHistoryBinding(fetchHistory: input.fetchHistoryList)
        
        submissionModel.withLatestFrom(historyData){  submission, original in
            return original + submission
        }
        .subscribe(with: self,onNext: { vm, submission in
            vm.historyData.accept(submission)
        }).disposed(by: disposeBag)

        
        input.deleteHistory
            .asObservable()
            .withUnretained(self)
            .flatMap { vm, index -> Observable<(Int, [SubmissionVO])> in
                let index: Observable<Int> = .just(index)
                let data: Observable<[SubmissionVO]> = vm.historyData.take(1).asObservable()
                return Observable.zip(index, data)
            }
            .withUnretained(self)
            .flatMap { vm, tuple in
                let (index, historydatas) = tuple
                let deletedSubmissionVo = historydatas[index]
                
                let values = historydatas.filter {
                    if deletedSubmissionVo.id == $0.id { return false }
                    return true
                }
                // TODO: View에 반영 해야함
                return vm.historyUsecase.deleteItem(item: deletedSubmissionVo)
                    .andThen(Observable.just(values))
            }
            .subscribe(with: self, onNext: { vm, value in
                vm.historyData.accept(value)
            }).disposed(by: disposeBag)
        
        let filteredHistoryData =
        Driver<[SubmissionVO]>.combineLatest(historyData.asDriver(),
                                           input.currentSegment)
        {   submissions, segment in
            let filteredSubmissions = submissions.filter{ $0.statusCode.checkIsEqual(with: segment) }
            return filteredSubmissions
        }
        
        historyUsecase.fetchFavoriteProblem()
            .subscribe(with: self, onNext: { vm, favoriteProblems in
                Log.debug("즐겨찾기 한 문제 : \(favoriteProblems)")
            }).disposed(by: disposeBag)
        
            // filteredHistoryData.asObservable()
            //   .subscribe(with: self,onNext: { vm,value in
                // TODO: 현재 Filter해서 fetch 해오는 Query 부재 -> 기능 추후 제공
                // -> 즐겨찾기와 임시저장만 추가
            //   }).disposed(by: disposeBag)
        
        return Output(historyData: filteredHistoryData,
                      paginationRefreshEndEvent: refreshEndEvent.asSignal(),
                      paginationLoading: paginationLoading.asDriver(onErrorJustReturn: false),
                      refreshClearEvent: refreshClearEvent.asSignal())
    }
    
    func observingSubmission() {
        sendSubmission
            .withLatestFrom(historyData){ value, original in
                Log.debug("added Values : \(value)")
                return [value] + original
            }.subscribe(with: self, onNext: { vm, value in
                vm.historyData.accept(value)
            }).disposed(by: disposeBag)
    }
    
    
    func viewDidLoadBinding(viewDidLoad: Signal<Void>){
        viewDidLoad
            .asObservable()
            .withUnretained(self)
            .flatMap { vm, _ in vm.fetchSubmissionHistory() }
            .subscribe(with: self, onNext: { vm, data in
                vm.submissionModel.accept(data)
                vm.refreshEndEvent.accept(())
                vm.paginationLoading.accept(false)
            }).disposed(by: disposeBag)
    }
    
    func fetchHistoryBinding(fetchHistory list: Signal<Void>) {
        list
            .withUnretained(self)
            .filter{ vm, _ in
                if vm.currentPage >= vm.totalPage {
                    vm.paginationLoading.accept(false)
                    vm.refreshEndEvent.accept(())
                    return false
                }
                return true
            }
            .delay(.milliseconds(300))
            .flatMap {vm, _ in
                vm.historyUsecase.fetchSubmission(offset: vm.currentPage).asSignal(onErrorJustReturn: [])
            }
            .emit(with: self,onNext: { vm, datas in
                if !datas.isEmpty {
                    vm.submissionModel.accept(datas)
                    vm.currentPage += 1
                }
                // TODO: Fall Back UI Present 필요
                vm.refreshEndEvent.accept(())
                vm.paginationLoading.accept(false)
            }).disposed(by: disposeBag)
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
                vm.paginationLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchSubmissionHistory() -> Observable<[SubmissionVO]> {
        let localTempSubmission
        = historyUsecase
            .fetchProblemHistoryEqualStatus(status: "temp")
            .compactMap { try $0.get() }
        
        let fetchedSubmission =
        historyUsecase
            .fetchSubmission(offset: self.currentPage)
            .do(onNext: { [weak self] _ in self?.currentPage += 1 })
        
        return Observable<[SubmissionVO]>.concat([localTempSubmission, fetchedSubmission])
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
        //        _ = service.getMeSubmissions(query: Query.getMeSubmissions())
    }
    
    private func requestMe(){
        // TODO: - 현재 SolvedProblem만 가지고 온다.
        // 에러나 성공 실패 했을때의 결과에 대한 Submission을 가지고 오기 위해서는
        // Submission에 조건을 달아서 query를 날려야 하나?
        //        service.getMe(query: Query.getMe())
        //            .subscribe(with: self, onSuccess: { vm , me in
        //                Log.debug(me)
        //            })
//        _ = service.getSubmission(query: Query.getSubmission(),cache: .fetchIgnoringCacheCompletely)
//        _ = service.getMeSubmissions(.SUB_LIST(arg: GRAR.init(offset: 0)))
        //TODO: 확인 필요
//            .map { $0 }
//            .map { $0.map { fr in fr.toDomain() }}
//            .subscribe(with: self, onSuccess: { vm, value in
//                vm.submissionModel.accept([])
//                vm.historyData.accept([])
//                vm.historyData.accept(value)
//            })
    }
}
