//
//  UIControl.swift
//  CommonUI
//
//  Created by 박형환 on 4/10/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit
import Combine

extension UIView {
    func gesture(_ gestureType: AnimateTexts.GestureType = .tap()) -> AnimateTexts.GesturePublisher {
        AnimateTexts.GesturePublisher(
            view: self,
            gestureType: gestureType
        )
    }
}

enum AnimateTexts {
    final class GestureSubscription<S: Subscriber>: Subscription where S.Input == GestureType {
        
        private var subscriber: S?
        private var gestureType: GestureType
        private var view: UIView
        init(subscriber: S, view: UIView, gestureType: GestureType) {
            self.subscriber = subscriber
            self.view = view
            self.gestureType = gestureType
            configureGesture(gestureType)
        }
        
        private func configureGesture(_ gestureType: GestureType) {
            let gesture = gestureType.get()
            gesture.addTarget(self, action: #selector(handler))
            view.addGestureRecognizer(gesture)
        }
        
        @objc func handler(_ sender: Any) {
            _ = subscriber?.receive(gestureType)
        }
        
        func request(_ demand: Subscribers.Demand) { }
        
        func cancel() {
            subscriber = nil
        }
    }

    struct GesturePublisher: Publisher {
        
        typealias Output = GestureType
        typealias Failure = Never
        
        private let view: UIView
        private let gestureType: GestureType
        
        init(view: UIView, gestureType: GestureType) {
            self.view = view
            self.gestureType = gestureType
        }
        func receive<S>(subscriber: S) where S : Subscriber,
        GesturePublisher.Failure == S.Failure, GesturePublisher.Output
        == S.Input {
            let subscription = GestureSubscription(
                subscriber: subscriber,
                view: view,
                gestureType: gestureType
            )
            subscriber.receive(subscription: subscription)
        }
    }

    enum GestureType {
        case tap(UITapGestureRecognizer = .init())
        case longPress(UILongPressGestureRecognizer = .init())
        func get() -> UIGestureRecognizer {
            switch self {
            case let .tap(tapGesture):
                return tapGesture
            case let .longPress(longPressGesture):
                return longPressGesture
           }
        }
    }
}

extension UIControl {
    func eventPublisher(_ event: UIControl.Event) -> AnyPublisher<UIControl, Never> {
        EventPublisher(
            control: self,
            event: .touchUpInside
        )
        .throttle(
            for: .seconds(0.4),
            scheduler: RunLoop.main,
            latest: false
        )
        .eraseToAnyPublisher()
    }
    
    struct EventPublisher<C: UIControl>: Publisher {
        typealias Output = C
        typealias Failure = Never
        
        private let control: C
        private let event: C.Event
        
        init(control: C, event: UIControl.Event) {
            self.control = control
            self.event = event
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, C == S.Input {
            let subscription = 
            EventSubscription(
                s: subscriber,
                control: control,
                event: event
            )
            subscriber.receive(subscription: subscription)
        }
    }
    
    final class EventSubscription<S: Subscriber, C: UIControl>: Subscription where S.Input == C {
        
        var subscriber: S?
        var control: C
        
        init(s: S, control: S.Input, event: UIControl.Event) {
            subscriber = s
            self.control = control
            control.addTarget(self, action: #selector(controlEvent(_:)), for: event)
        }
        
        @objc func controlEvent(_ sender: Any) {
            _ = subscriber?.receive(control)
        }
        
        func request(_ demand: Subscribers.Demand) {
            
        }
        
        func cancel() {
            subscriber = nil
        }
    }
}


