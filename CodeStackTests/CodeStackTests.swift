//
//  CodeStackTests.swift
//  CodeStackTests
//
//  Created by 박형환 on 2023/04/15.
//

import XCTest
@testable import CodeStack
import RxSwift
import RxTest
import RxCocoa
import Combine

final class CodeStackTests: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
    }
    
    enum TestError: Error {
        case apiError
        case maxCalled
    }
    
    func pagination(limit: Int, offset: Int) -> Observable<Result<[Int],TestError>> {
        var arr: [Int?] = (0..<limit).map { $0 }
        arr[3] = nil
        
        return Observable<Result<[Int],TestError>>.create { ob in
            
//            ob.onNext(.success(<#T##[Int]#>))
            return Disposables.create()
        }
    }
    
    func testRxSwift() {
        let observable: Observable<Int>
        =
        Observable<Int>.create { ob in
            ob.onNext(1)
            ob.onNext(2)
            ob.onNext(3)
            ob.onNext(4)
            ob.onError(TestError.apiError)
            return Disposables.create()
        }
        
        observable
            .retry(when: { error in
                print("error: \(error)")
                return error
                    .scan(0) { prevalue, newValue in
                        guard prevalue < 3 else { throw TestError.maxCalled }
                        return prevalue + 1
                    }
            })
            .subscribe (
                onNext: { value in
                Log.debug(value)
            },onError: {  error in
                Log.error(error)
            },onCompleted: {
                Log.debug("completed")
            },onDisposed: {
                Log.debug("disposed")
            })
        
    }

    
    func testMap_Range() {
        
        
        // 1
//        let subject = PassthroughSubject<Int, Never>()
//        // 2
//        let publisher = subject.shareReplay(capacity: 2)
        
        
        // Initializes test scheduler.
        // Test scheduler implements virtual time that is
        // detached from local machine clock.
        // This enables running the simulation as fast as possible
        // and proving that all events have been handled.
        let scheduler = TestScheduler(initialClock: 0)
        
        // Creates a mock hot observable sequence.
        // The sequence will emit events at designated
        // times, no matter if there are observers subscribed or not.
        // (that's what hot means).
        // This observable sequence will also record all subscriptions
        // made during its lifetime (`subscriptions` property).
        let xs = scheduler.createHotObservable([
            .next(150, 1),  // first argument is virtual time, second argument is element value
            .next(210, 0),
            .next(220, 1),
            .next(230, 2),
            .next(240, 4),
            .completed(300) // virtual time when completed is sent
        ])
        
        // `start` method will by default:
        // * Run the simulation and record all events
        //   using observer referenced by `res`.
        // * Subscribe at virtual time 200
        // * Dispose subscription at virtual time 1000
        let res = scheduler.start { xs.map { $0 * 2 } }
        
        let correctMessages = Recorded.events(
            .next(160, 1 * 2),
            .next(210, 0 * 2),
            .next(220, 1 * 2),
            .next(230, 2 * 2),
            .next(240, 4 * 2),
            .completed(300)
        )
        
        let correctSubscriptions = [
            Subscription(100, 300)
        ]
        
//        XCTAssertEqual(res.events, correctMessages)
//        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
