

import XCTest
@testable import Domain
import RxTest
import RxBlocking
import RxSwift

final class DefaultSubmissionUsecaseTest: XCTestCase {
    
    var usecase: SubmissionUseCase!
    var dbRepository: MockDBRepository!
    var disposebag: DisposeBag!
    override func setUpWithError() throws {
        dbRepository = MockDBRepository()
        let webRepository = MockWebRepository()
        let submissionRepository = MockSubmissionRepository()
        usecase = DefaultSubmissionUseCase(dbRepository: dbRepository,
                                           webRepository: webRepository,
                                           submissionReposiotry: submissionRepository)
        disposebag = DisposeBag()
    }
    
    override func tearDownWithError() throws {
        disposebag = nil
        dbRepository = nil
        usecase = nil
    }
    
    func test_submission_send_action() throws {
        let expectation = XCTestExpectation(description: "error Test")
        let submissionVO = SubmissionVO.mock
        
        usecase.submitSubmissionAction(model: submissionVO)
            .subscribe(with: self, onNext: {vc, value in
                
                if case let .success(subVO) = value {
                    XCTAssertEqual(subVO.problem, submissionVO.problem, "problem Equal")
                    XCTAssertEqual(subVO.statusCode, .RE, "Problem Must change")
                    XCTAssertEqual(subVO.id, submissionVO.id, "id Equal")
                    XCTAssertEqual(subVO.language, submissionVO.language, "Language Equal")
                    XCTAssertEqual(subVO.sourceCode, submissionVO.sourceCode, "sourceCode Equal")
                }
                if case .failure = value {
                    XCTAssert(false)
                }
                
                expectation.fulfill()
            }).disposed(by: disposebag)
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test_같은_소스코드일경우_SendError() throws {
        let expectation = XCTestExpectation(description: "error Test")
        
        usecase.submitSubmissionAction(model: .sample)
            .subscribe(with: self, onNext: {vc, value in
                if case let .failure(error) = value {
                    XCTAssertNotNil(error as? SendError)
                    XCTAssertEqual(error as! SendError, SendError.isEqualSubmission)
                }
                
                expectation.fulfill()
            }).disposed(by: disposebag)
        
        wait(for: [expectation], timeout: 5)
    }
    
    
    func test_제출결과_임시저장_제외한_History_가져오기() throws {
        let expectation = XCTestExpectation(description: "error Test")
        
        usecase.fetchProblemSubmissionHistory(id: "1", state: .temp)
            .subscribe(with: self, onNext: { vc, value in
                if case let .success(submissions) = value {
                    XCTAssert(submissions.count >= 0,  "Temp를 제외한 카운트")
                    submissions.forEach { vo in
                        XCTAssertNotEqual(vo.statusCode, .temp , "Not Temp")
                    }
                    expectation.fulfill()
                }
            }).disposed(by: disposebag)
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test_제출결과_특정_SolveStatus제외하는경우() throws {
        let expectation = XCTestExpectation(description: "error Test")
        
        let problemID: ProblemID = UUID().uuidString
        
        let blockAC = usecase.fetchProblemSubmissionHistory(id: problemID, state: .AC).toBlocking(timeout: 2)
        let blockOLE = usecase.fetchProblemSubmissionHistory(id: problemID, state: .OLE).toBlocking()
        let blockPE = usecase.fetchProblemSubmissionHistory(id: problemID, state: .PE).toBlocking()
        let blockWA = usecase.fetchProblemSubmissionHistory(id: problemID, state: .WA).toBlocking()
        let blocktemp = usecase.fetchProblemSubmissionHistory(id: problemID, state: .temp).toBlocking()
        let blockfavorite = usecase.fetchProblemSubmissionHistory(id: problemID, state: .favorite).toBlocking()
        
        try [
            (blockAC, SolveStatus.AC),
            (blockOLE, SolveStatus.OLE),
            (blockPE, SolveStatus.PE),
            (blockWA, SolveStatus.WA),
            (blocktemp, SolveStatus.temp),
            (blockfavorite, SolveStatus.favorite)
        ].map { block in
            let (block, status) = block
            let resultArr = try block.toArray()
            print(resultArr.count)
            XCTAssertEqual(resultArr.count, 1)
            resultArr.forEach {
                if case let .success(submissionVOs) = $0 {
                    XCTAssert(submissionVOs.count >= 0,  "Status 를 제외한 값")
                    submissionVOs.forEach { vo in
                        print(vo.statusCode)
                        XCTAssertNotEqual(vo.statusCode, status , "Not Answer")
                    }
                }
            }
        }
    }
    
    /// MARK: 이미 임시저장이 되어있을 경우 무시 // // 최근 기록이 같을때
    /// 다른 내용일때 임시저장 업데이트
    /// 같은 내용일때 그냥 dissmiss
    func test_문제_변경사항_업데이트_액션() throws {
        // 내용이 없을때 임시저장 Action
        // Update 성공할시 True 반환
        var submissionTestCase = SubmissionVO.test(problemID: "10")
        let updateAction1 = usecase.updateSubmissionAction(model: submissionTestCase).toBlocking()
        XCTAssertTrue(try updateAction1.toArray().first!)
        
        // 추후 저장된 상태에서 추가로 같은 ProblemID의 submission을 추가할시
        // 내용을 보고 다른내용이라면 교체플로우를 진행하고, 똑같은 내용이라면 추가하지 않습니다.
        var submissionTestCase2 = SubmissionVO.test(problemID: "10")
        let updateAction2 = usecase.updateSubmissionAction(model: submissionTestCase2).toBlocking()
        let state = try updateAction2.toArray()
        XCTAssertTrue(state.count == 1)
        XCTAssertFalse(state.first!, "같은 내용이라면 False를 반환 후 DB에 추가 하지 않습니다.")
        
        
        var submissionTestCase3 = SubmissionVO.test(problemID: "10", sourceCode: "print(\"hello world\") ㅋㄷ")
        let updateAction3 = usecase.updateSubmissionAction(model: submissionTestCase3).toBlocking()
        let state2 = try updateAction3.toArray()
        XCTAssertTrue(state2.count == 1)
        XCTAssertTrue(state2.first!, "다른 내용일 경우 Update를 진행하고 True를 반환합니다.")
        
        
        // DBRepository 의 상태 State
        let dbRepositoryState = dbRepository.fetchProblemState(.all).toBlocking()
        
        let problemSubmissionStateList = try dbRepositoryState.first()
        print(problemSubmissionStateList!.first!.submissions)
        XCTAssertEqual(
            problemSubmissionStateList!.first!.submissions.count, 2,
            "submission을 저장할때 , 해당 ProblemID를 추적하는 ProblemState가 추가되야 합니다." +
            "submission을 같은내용 2번, 다른내용 1번 -> 3번의 Action에서 추가 되어야 하는 Submission은 2개입니다."
        )
    }
    
    func test_제출_날짜_Calendar_저장_액션() throws {
        let first = try usecase.fetchSubmissionCalendar().toBlocking()
        let value = try first.first()
        XCTAssertNotNil(value)
        let calendar = try value?.get()
        XCTAssert(calendar!.dates.count == 0)
        
        let models: [SubmissionVO] = [
            SubmissionVO.test(problemID: "0",statusCode: .AC, date: "2023-12-12"),
            SubmissionVO.test(problemID: "1",statusCode: .AC, date: "2023-12-12"),
            SubmissionVO.test(problemID: "2", statusCode: .OLE, date: "2023-12-13"),
            SubmissionVO.test(problemID: "3", statusCode: .RE, date: "2023-12-14"),
            SubmissionVO.test(problemID: "4", statusCode: .MLE, date: "2023-12-15"),
            SubmissionVO.test(problemID: "5", statusCode: .favorite, date: "2023-12-16"),
            SubmissionVO.test(problemID: "6", statusCode: .WA, date: "2023-12-17")
        ]
        
        for model in models {
            let values = usecase.submitSubmissionAction(model: model).toBlocking()
            let responseResult = try values.first()
            XCTAssertNotNil(responseResult)
            let responseSubmission = try responseResult!.get()
        }
        
        let block = try usecase.fetchSubmissionCalendar().toBlocking()
        let values = try block.first()
        let result = try values?.get()
        XCTAssertEqual(result!.dates.count, 7)
    }
    
    func test_즐겨찾기_update() throws {
        
        let testModel = FavoriteProblemVO(problemID: "1",
                                          problmeTitle: "hello",
                                          createdAt: Date())
        
        let block = usecase.updateFavoritProblem(model: testModel, flag: true).toBlocking()
        let testFavoriteResult = try block.first()?.get()
        let block2 = usecase.updateFavoritProblem(model: testModel, flag: false).toBlocking()
        let testUnFavoriteResult = try block2.first()?.get()
        
        XCTAssertTrue(testFavoriteResult!)
        XCTAssertFalse(testUnFavoriteResult!)
    }
    
    func test_특정문제_즐겨찾기여부() throws {
        let empty = usecase.fetchIsFavorite(problemID: "").toBlocking()
        let testFavorite = usecase.fetchIsFavorite(problemID: "TestID1234").toBlocking()
        
        let emptyFlag = try empty.first()
        XCTAssertNotNil(emptyFlag)
        XCTAssertFalse(emptyFlag!, "\(emptyFlag)")
        
        let favoriteFlag = try testFavorite.first()
        XCTAssertNotNil(favoriteFlag)
    }
    
}
