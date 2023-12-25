//
//  Reactive-UIViewController.swift
//  CodestackApp
//
//  Created by 박형환 on 12/24/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    var viewDidLoad: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
        return ControlEvent(events: source)
    }
}


/// Name Space For Rx Observable
public enum OB { }

public extension OB {
    static func justVoid() -> Signal<Void> {
        return .just(()).asSignal()
    }
}

extension ObservableConvertibleType where Element == String {
    func asDriverJust() -> Driver<String> {
        self.asObservable().asDriver(onErrorJustReturn: "")
    }
    
    func asSignalJust() -> Signal<String> {
        self.asObservable().asSignal(onErrorJustReturn: "")
    }
}
