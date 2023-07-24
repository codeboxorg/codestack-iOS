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
g
class HistoryViewModel: ViewModelType{
    
    struct Input{
        var viewDidLoad: Signal<Void>
        var currentSegment: Signal<SolveStatus>
    }
    
    struct Output{
        var segmentPage: Driver<SolveStatus>
        var historyData: Driver<[Submission]>
    }
    
    private var disposeBag = DisposeBag()
    
    private let selectedPage = PublishRelay<SolveStatus>()
    
    private let dummyData = PublishRelay<[Submission]>()
    
    #if DEBUG
    private let testService: TestService = NetworkService()
    #endif
    
    func transform(input: Input) -> Output {
        
        input.currentSegment
            .compactMap{[weak self] value in
                guard let self else { return nil}
//                Log.debug("currentSegment: \()")
                if value == .none{
                    return self.testService.request().content
                }else{
                    return self.testService.request(type: value).content
                }
            }
            .emit(to: dummyData)
            .disposed(by: disposeBag)
        
        
        input.viewDidLoad
            .compactMap{[weak self] _ in
                guard let self else { return nil}
                return self.testService.request(type: .temp).content
            }.emit(to: dummyData)
            .disposed(by: disposeBag)
        
        
        return Output(segmentPage: selectedPage.asDriver(onErrorJustReturn: .none),
                      historyData: dummyData.asDriver(onErrorJustReturn: []))
    }
    
    private func getDummy(type seg: SegType) -> [String] {
        switch seg {
        case .favorite:
            return ["hello","안녕하세ㅛ","테스트중입니다.","hello","안녕하세ㅛ","테스트중입니다.","hello","안녕하세ㅛ","테스트중입니다."]
        case .tempSave:
            return ["테스트중입니다.","테스트중입니다.","테스트중입니다.","테스트중입니다."]
        case .success:
            return ["hello","테스트중입니다.","hello"]
        case .failure:
            return ["hello","hello","hello","hello","hello"]
        case .all:
            return ["sheet"] + ["hello","안녕하세ㅛ","테스트중입니다.","hello","안녕하세ㅛ","테스트중입니다.","hello","안녕하세ㅛ","테스트중입니다."] + ["시b"]
        }
    }
}

