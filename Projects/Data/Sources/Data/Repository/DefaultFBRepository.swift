//
//  FBRepository.swift
//  Data
//
//  Created by 박형환 on 1/9/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import RxSwift
import Domain
import Global
import CSNetwork
import FirebaseAuth


public final class DefaultFBRepository: FBRepository {
    
    private let rest: RestAPI
    private let trackTokenService: TrackService
    
    public init(rest: RestAPI, trackTokenService: TrackService) {
        self.rest = rest
        self.trackTokenService = trackTokenService
    }
    
    public func uploadProblem(_ problem: ProblemVO) -> Observable<State<Void>> {
        let token = KeychainItem.currentFBIdToken
        let problemDTO = ProblemDTO(id: problem.id,
                                    title: problem.title,
                                    contextID: problem.context,
                                    languages: problem.languages.map(\.name),
                                    tags: problem.tags.map(\.name),
                                    accepted: "0",
                                    submission: "0",
                                    maxCpuTime: "0",
                                    maxMemory: "0")
        let endPoint = FireStoreProblemEndPoint(post: problemDTO, token)
        return rest.post(endPoint)
            .andThen(Observable.just(.success(())))
            .retry(when: { [weak self] errorObservable in
                guard let self else { return Observable<Void>.never() }
                return errorObservable.renewToken(with: self.trackTokenService)
            })
            .catch { Observable.just(.failure($0)) }
    }
    
    public func fetchProblem() -> Observable<[ProblemVO]> {
        let token = KeychainItem.currentFBIdToken
        let endPoint = FireStoreProblemEndPoint(token)
        return rest.request(endPoint, operation: { data in
            try JSONDecoder().decode(FBDocuments<ProblemDTO>.self, from: data)
        })
        .retry(when: { [weak self] errorObservable in
            guard let self else { return Observable<Void>.never() }
            return errorObservable.renewToken(with: self.trackTokenService)
        })
        .map { $0.toDomain() }
        .asObservable()
    }
    
    public func fireStorePost() -> Observable<DocumentVO> {
        let endpoint = FireStoreEndPoint(KeychainItem.currentFBIdToken)
        return rest.request(endpoint) { op in
            try JSONDecoder().decode(FBDocuments<Store>.self, from: op)
        }
        .retry(when: { [weak self] errorObservable in
            guard let self else { return Observable<Void>.never() }
            return errorObservable.renewToken(with: self.trackTokenService)
        })
        .map { $0.toDomain() }
        .asObservable()
    }
    
    public func fireStorePostMe() -> Observable<DocumentVO> {
        let uid = KeychainItem.currentFBLocalID
        let token = KeychainItem.currentFBIdToken
        let endpoint = FireStoreEndPoint(token, uid)
        return rest.request(endpoint) { op in
            try JSONDecoder().decode(FBDocuments<Store>.self, from: op)
        }
        .retry(when: { [weak self] errorObservable in
            guard let self else { return Observable<Void>.never() }
            return errorObservable.renewToken(with: self.trackTokenService)
        })
        .map { $0.toDomain() }
        .asObservable()
    }
    
    public func fetchOtherUser(uid: String) -> Observable<FBUserNicknameVO> {
        let idtoken = KeychainItem.currentFBIdToken
        let query = UserGetQuery(uid: uid, token: idtoken, method: .get)
        return rest.request(FireStoreUserPostEndPoint(get: query)) { data in
            try JSONDecoder().decode(FBUserDTO.self, from: data)
        }
        .map {$0.toDomain() }
        .asObservable()
    }
    
    public func fsProfileUpdate(_ member: MemberVO) -> Observable<String> {
        .empty()
    }
    
    public func update(email: String) -> Maybe<String> {
        Maybe<String>.create { maybe in
            let dispatchItem = DispatchWorkItem {
                // MARK: Send Email Using FB
                FAuth.auth().currentUser?.updateEmail(to: email) { error in
                    if let error { maybe(.error(error))}
                    else { maybe(.success(email))}
                }
            }
            dispatchItem.perform()
            return Disposables.create { dispatchItem.cancel() }
        }
    }
    
    public func update(nickname: String) -> Completable {
        let firebaseIDToken = KeychainItem.currentFBIdToken
        let uid = KeychainItem.currentFBLocalID
        let query = UserGetQuery(uid: uid, token: firebaseIDToken, method: .patch)
        let profilePath = UserManager.profileImage ?? ""
        let userQuery = UserQuery(nickname: nickname, preferLanguage: "", profileImagePath: profilePath, query: query)
        return rest.post(FireStoreUserPostEndPoint(patch: userQuery))
            .retry(when: { [weak self] errorObservable in
                guard let self else { return Observable<Void>.never() }
                return errorObservable.renewToken(with: self.trackTokenService)
            })
    }
    
    public func update(profileImage: Data, nickname: String) -> Observable<String> {
        let path = nickname
        let endPoint = StorageEndPoint(path, body: profileImage, token: KeychainItem.currentFBIdToken)
        
        return rest.post(endPoint, operation: { data in
            let json = try JSONDecoder().decode([String: String].self, from: data)
            if let token = json["downloadTokens"] {
                let imageFullPath =
                endPoint.scheme + "://" + endPoint.host + endPoint.path +
                "?alt=media" + "&" + "token=\(token)"
                UserManager.profileImage = imageFullPath
            }
        })
        .andThen(Observable.just("success"))
        .withUnretained(self)
        .flatMap { repo, _ in
            repo.updateProfileImageInStore()
                .map { _ in UserManager.profileImage ?? "" }
        }
        .retry(when: { [weak self] errorObservable in
            guard let self else { return Observable<Void>.never() }
            return errorObservable.renewToken(with: self.trackTokenService)
        })
    }
    
    public func fetchMyProfileImage() -> Observable<Data> {
        guard let path = UserManager.profileImage else { return .empty() }
        let endPoint = StorageProfileEndPoint(path)
        return rest.request(endPoint, operation: { data in data}).asObservable()
            .retry(when: { [weak self] errorObservable in
                guard let self else { return Observable<Void>.never() }
                return errorObservable.renewToken(with: self.trackTokenService)
            })
    }
}

extension DefaultFBRepository {
    private func updateProfileImageInStore() -> Observable<String> {
        let firebaseIDToken = KeychainItem.currentFBIdToken
        let uid = KeychainItem.currentFBLocalID
        let query = UserGetQuery(uid: uid, token: firebaseIDToken, method: .patch)
        let profilePath = UserManager.profileImage ?? ""
        let nickname = UserManager.nickName ?? ""
        
        let userQuery = UserQuery(nickname: nickname,
                                  preferLanguage: "",
                                  profileImagePath: profilePath,
                                  query: query)
        
        let endPoint = FireStoreUserPostEndPoint(patch: userQuery)
        
        return rest.post(endPoint).andThen(Observable.just("Success"))
            .retry(when: { [weak self] errorObservable in
                guard let self else { return Observable<Void>.never() }
                return errorObservable.renewToken(with: self.trackTokenService)
            })
    }
}
