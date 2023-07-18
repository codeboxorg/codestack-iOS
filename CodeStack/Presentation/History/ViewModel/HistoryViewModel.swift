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

class HistoryViewModel: ViewModelType{
    
    struct Input{
        var viewDidLoad: Signal<Void>
        var currentSegment: Signal<SegType>
    }
    
    struct Output{
        var segmentPage: Driver<SegType>
        var historyData: Driver<[String]>
    }
    
    private var disposeBag = DisposeBag()
    
    private let selectedPage = PublishRelay<SegType>()
    
    private let dummyData = PublishRelay<[String]>()
    
    func transform(input: Input) -> Output {
        
        input.currentSegment
            .map(getDummy(type:))
            .emit(to: dummyData)
            .disposed(by: disposeBag)
        
        
        return Output(segmentPage: selectedPage.asDriver(onErrorJustReturn: .all),
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
g
