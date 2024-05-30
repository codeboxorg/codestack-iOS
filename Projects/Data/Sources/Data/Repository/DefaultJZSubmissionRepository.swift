//
//  DefaultJZSubmissionRepository.swift
//  Data
//
//  Created by 박형환 on 4/22/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import Domain
import RxSwift
import CSNetwork
import Global


public final class DefaultJZSubmissionRepository: JZSubmissionRepository {
    private let rest: RestAPI
    private let scheduler: SchedulerType = MainScheduler.asyncInstance
    
    public init(rest: RestAPI) {
        self.rest = rest
    }
    
    public func jzAuthentificate() -> Observable<Bool> {
        let endPoint = JZAuthEndpoint()
        return rest.request(endPoint, operation: { data in })
        .map { _ in false }
        .asObservable()
    }
    
    public func perform(code: String, languageID: Int, problemVO: ProblemVO) -> Observable<State<SubmissionToken>> {
        let dto = makeDTO(code: code, languageID: languageID, problemVO: problemVO)
        let endpoint = JZSubmissionEndpoint(dto: dto)
        
        return rest.request(endpoint, operation: { data in
            try JSONDecoder().decode(JZSubmissionTokenResponse.self, from: data)
        })
        .map { .success($0.token) }
        .asObservable()
        .catch { [weak self] error in
            guard let self else { return .just(.failure(error)) }
            let result = self.sendError(.failure(error))
            return Observable.just(result)
        }
    }
    
    public func getSubmission(token: SubmissionToken) -> Observable<JudgeZeroSubmissionVO> {
        let endPoint = JZFetchSubmissionEndpoint.init(token: token)
        return rest.request(endPoint, operation: { data in
            let dto = try JSONDecoder().decode(JudgeSubmissionResponseDTO.self, from: data)
            if let status = dto.status, let err = status.toDomain().isProcessing() {
                throw err
            } else {
                return dto
            }
        })
        .asObservable()
        .map { $0.toDomain() }
        .retry(when: { [weak self] error -> Observable<Int> in
            guard let self else { return Observable.just(0) }
            return error.flatMap { isComplete in
                if self.shouldRetry(for: isComplete) {
                    return self.isProccessing()
                } else {
                    return Observable.error(isComplete)
                }
            }
        })
        .take(3)
    }
}

private extension DefaultJZSubmissionRepository {
    func shouldRetry(for error: Error) -> Bool {
        return (error as? JZError) == .isProcessing
    }
    
    func isProccessing() -> Observable<Int> {
        Observable<Int>.timer(.seconds(3), period: nil, scheduler: scheduler)
    }
    
    func sendError(_ result: Result<Void, Error>) -> State<SubmissionToken> {
        switch result {
        case let .failure(error) where (error as? APIError) == APIError.httpResponseError(code: 429):
            return .failure(JZError.exceededUsage)
        default:
            return .failure(JZError.unknown)
        }
    }
    
    func makeDTO(code: String, languageID: Int, problemVO: ProblemVO) -> JudgeZeroSubmissionRequestDTO {
        
        let cpuTime = Double(problemVO.maxCpuTime)
        
        let wall_time_limit
        = if let cpuTime, cpuTime > 0 {
            cpuTime
        } else {
            8.0
        }
        
        return JudgeZeroSubmissionRequestDTO(sourceCode: code,
                                             languageID: languageID,
                                             stdin: problemVO.expectOutput.first,
                                             expected_output: problemVO.probleminput.first,
                                             wall_time_limit: wall_time_limit)
    }
    
}
