//
//  TokenTest.swift
//  Data
//
//  Created by 박형환 on 3/17/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import XCTest
@testable import Data
@testable import CSNetwork
@testable import Domain
import RxBlocking
import RxTest
import RxSwift

final class MockKeychain {
    static var storage: [String: String] = [:]
    
    static func saveTestToken(token: String) {
        storage["Token"] = token
    }
    
    static func getTestToken() -> String {
        storage["Token"] ?? ""
    }
}

class DefaultTokenTest: XCTestCase {
    
    var disposebag: DisposeBag!
    var sut: DefaultFBRepository!
    var service: TrackService!
    var mockURLSession: URLSessionProtocol!
    
    override func setUpWithError() throws {
        MockKeychain.saveTestToken(token: TestToken.token)
        service = TrackService {
            Completable.create { [weak self] com in
                guard let self else { return Disposables.create { } }
                let token = UUID().uuidString
                MockKeychain.saveTestToken(token: token)
                com(.completed)
                return Disposables.create { }
            }
        }
        disposebag = DisposeBag()
    }
    
    override func tearDownWithError() throws {
        disposebag = nil
        sut = nil
        try KeychainItem.deleteFirebaseToken()
    }
    
    
    /// 토큰 재발급 테스트
    func testReTryRequest() throws {
        let session = MockURLSession(response: (nil, nil, nil) )
        let api = MockRestAPI(mockSession: session)
        sut = DefaultFBRepository(rest: api, trackTokenService: service)
        
        let expectation = XCTestExpectation(description: "토큰 reissue 후 decoding error")
        sut.fetchPostLists(offset: 0, limit: 20)
            .subscribe(onError: { error in
                let err = error as? APIError
                if case .decodingError = err! {
                    XCTAssert(true)
                } else {
                    XCTAssert(false)
                }
                expectation.fulfill()
            }).disposed(by: disposebag)
        
        wait(for: [expectation])
    }
    
    /// 토큰 재발급 테스트
    func testReissueToken() throws {
        let scheduler = TestScheduler(initialClock: 0)
        
        let observable = scheduler.createColdObservable([
                    .next(210, "A"),
                    .next(220, "B"),
                    .error(230, APIError.httpResponseError(code: 401)),
                ])
        
        let res = scheduler.start(created: 0, subscribed: 0, disposed: 1000) {
            observable.asObservable()
                .retry(when: { [unowned self] error in
                    self.service.trackErrors(for: error) }
                )
        }
        
        let event = Recorded.events([
            .next(210, "A"),
            .next(220, "B"),
            .next(440, "A"),
            .next(450, "B"),
            .next(670, "A"),
            .next(680, "B"),
            .next(900, "A"),
            .next(910, "B"),
            .error(920, APIError.maxRetryError)
        ])
        
        XCTAssertEqual(res.events, event)
        XCTAssertNotEqual(TestToken.token, KeychainItem.currentFBIdToken)
    }
}

