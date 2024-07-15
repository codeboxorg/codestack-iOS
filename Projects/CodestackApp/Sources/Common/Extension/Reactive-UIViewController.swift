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

extension Reactive where Base: UIButton {
    var title: ControlProperty<String?> {
        let getter: () -> String? = { [weak base] in
            return base?.title(for: .normal)
        }
        
        let setter: (String?) -> Void = { [weak base] title in
            base?.setTitle(title, for: .normal)
        }
        
        let values = Observable<String?>.create { observer in
            // 초기 title 값을 방출
            if let initialTitle = getter() {
                observer.onNext(initialTitle)
            }
            let controlEvent = base.rx.controlEvent(.valueChanged).map { getter() }
            let subscription = controlEvent.bind(to: observer)
            
            return Disposables.create {
                subscription.dispose()
            }
        }
        let valueSink = Binder(base) { button, title in
            setter(title)
        }
        
        return ControlProperty(values: values, valueSink: valueSink)
    }
}


/// Name Space For Rx Observable
public enum OB { }

public extension OB {
    static func justVoid() -> Signal<Void> {
        return .just(()).asSignal()
    }
}

public extension ObservableConvertibleType where Element == String {
    func asDriverJust() -> Driver<String> {
        self.asObservable().asDriver(onErrorJustReturn: "")
    }
    
    func asSignalJust() -> Signal<String> {
        self.asObservable().asSignal(onErrorJustReturn: "")
    }
}
public extension Observable {
    func skeletonDelay() -> Observable<Element> {
        self.delay(.milliseconds(400), scheduler: MainScheduler.instance)
    }
}

