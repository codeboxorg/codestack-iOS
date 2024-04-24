//
//  CodeEditorReactor.swift
//  CodestackApp
//
//  Created by 박형환 on 1/25/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import ReactorKit
import RxRelay
import Combine


//MARK: KeyBoard Input View Action Binding 을 위한 ReactorKit 도입
final class CodeEditorReactor: Reactor {
    
    enum Action {
        case send(String)
        case favorite
    }
    
    enum Mutation {
        case showingAlert(String)
        case favorite
    }
    
    struct State {
        @Pulse var alert: String = ""
    }
    
    private(set) var initialState: State
    
    init(initialState: State) {
        self.initialState = initialState
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .favorite:
            return .just(.showingAlert("hello"))
        case .send(let value):
            return .just(.showingAlert(value))
        }
    }
    
    func streamSubscribe() {
        asyncStream(String.self)
            .asObservable()
            .compactMap { $0 as? String }
            .share(replay: 1)
        
        let stream = asyncStream(String.self)   
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .favorite:
            return state
        case .showingAlert(let str):
            print("values: \(str)")
            state.alert = str
            return state
        }
    }
    
    
    public func asyncStream<T: Decodable>(_ type: T.Type) -> some AsyncSequence {
        AsyncThrowingStream<T, Error> { continuation in
            
        }
    }
}
