//
//  CombineViewController.swift
//  CodestackApp
//
//  Created by 박형환 on 1/24/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit
import Combine


public protocol CMSteps {}

enum CMStep: CMSteps, Equatable {
    case home
    case tab
    case history
}

class BaseCMViewController: UIViewController {
    var _cancelables = Set<AnyCancellable>()
    static let viewDidLoad = NSNotification.Name("cm_viewDidLoad")
    static let viewDissapear = NSNotification.Name("cm_viewDissapear")
    static let didMove = NSNotification.Name("cm_didMove")
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: BaseCMViewController.viewDissapear, object: self)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        NotificationCenter.default.post(name: BaseCMViewController.didMove, object: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.post(name: BaseCMViewController.viewDidLoad, object: self)
        
        Publishers.Concatenate(prefix: Just(false),
                               suffix: Publishers.Merge(Just(true).delay(for: 2,
                                                                         scheduler: DispatchQueue.main),
                                                        Just(false).delay(for: 3, 
                                                                          scheduler: DispatchQueue.main)))
        .sink(receiveValue: { values in
            print(values)
        }).store(in: &_cancelables)
    }
}

extension BaseCMViewController {
    
    /// Combine publisher, triggered when the view is being dismissed
    var dismissed: AnyPublisher<Bool, Never> {
        let dismissedSource = NotificationCenter.default
            .publisher(for: BaseCMViewController.viewDissapear)
            .map { [self] _ in self.isBeingDismissed }
            .eraseToAnyPublisher()
        
        let movedToParentSource = NotificationCenter.default
            .publisher(for: BaseCMViewController.didMove)
            .map { [self] _ in self.isBeingDismissed }
            .print("$0 isBeing move To Partes:")
            .eraseToAnyPublisher()

        return Publishers.Merge(dismissedSource, movedToParentSource)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /// Combine publisher, triggered when the view appearance state changes
    var displayed: AnyPublisher<Bool, Never> {
        let viewDidAppearPublisher = NotificationCenter.default
            .publisher(for: BaseCMViewController.viewDidLoad, object: self)
            .map { _ in true }
            .eraseToAnyPublisher()

        let viewDidDisappearPublisher = NotificationCenter.default
            .publisher(for: BaseCMViewController.viewDissapear, object: self)
            .map { _ in false }
            .eraseToAnyPublisher()

        // A UIViewController is at first not displayed
        let initialState = Just(false).eraseToAnyPublisher()
        
        return Publishers.Concatenate(prefix: initialState, 
                                      suffix: Publishers.Merge(viewDidAppearPublisher,
                                                               viewDidDisappearPublisher))
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
