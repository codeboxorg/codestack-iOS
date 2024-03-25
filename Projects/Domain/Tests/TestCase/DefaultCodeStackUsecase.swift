//
//  CodeStackUsecase.swift
//  DomainTests
//
//  Created by 박형환 on 2/28/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import XCTest
@testable import Domain
import RxBlocking
import RxTest
import RxSwift

class DefaultCodeStackUsecaseTests: XCTestCase {
    

    var usecase: FirebaseUsecase!
    var disposebag: DisposeBag!
    
    override func setUpWithError() throws {
        let mockRepo = MockFBRepository()
        
        usecase = FirebaseUsecase(fbRepository: mockRepo)
        disposebag = DisposeBag()
    }
    
    override func tearDownWithError() throws {
        disposebag = nil
        usecase = nil
    }
    
    
    func test_MarkDown_글올리기_Action() throws {
        
        let markdownID = UUID().uuidString
        let testStore = StoreVO(title: "정렬이란?",
                                name: "stormHwan",
                                date: Date().toString(),
                                description: "정렬 은 어떠한 기준점으로 오름차순 혹은 내림차순으로 순서대로 나열하도록 데이터를 배치하는 알고리즘이다.",
                                markdown: markdownID,
                                tags: ["정렬", "구현"])
        let markdown = "<body> 1. MegeSort ~~~ </body>"

        let first = usecase.writeContent(testStore, markdown).toBlocking()
        _ = try first.first()
        let fetched = usecase.fetchPostByID(markdownID).toBlocking()
        let result = try fetched.first()
        
        XCTAssertEqual(markdown, result!.markdown)
    }
    
    func test_글목록_가져오기() throws {
        let block = usecase.fetchPostInfoList().toBlocking()
        let result = try block.toArray()
        
        XCTAssert(result.first!.store.count == 0)
    }
}
