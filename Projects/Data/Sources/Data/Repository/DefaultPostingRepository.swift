



import Foundation
import RxSwift
import Domain
import Global
import CSNetwork
import FirebaseAuth

public final class DefaultPostingRepository: PostingRepository {
    
    private let rest: RestAPI
    private let trackTokenService: TrackService
    
    public init(rest: RestAPI, trackTokenService: TrackService) {
        self.rest = rest
        self.trackTokenService = trackTokenService
    }
    
    public func fetchPostLists(offset: Int = 0, limit: Int = 20) -> Observable<[StoreVO]> {
        let query = FirebaseQuery.postListQuery(offset, limit)
        let endpoint = FireStoreEndPoint(KeychainItem.currentFBIdToken, runQuery: query)
        
        return rest.request(endpoint) { op in
            try JSONDecoder().decode([QueryDocument<Store>].self, from: op)
        }
        .retry(when: { [weak self] errorObservable in
            guard let self else { return Observable<Void>.never() }
            return errorObservable.renewToken(with: self.trackTokenService)
        })
        .map { $0.toDomain().map { dto in dto.toDomain() } }
        .asObservable()
    }
    
    public func fetchPost(_ documentID: String) -> Observable<PostVO> {
        let endpoint = FireStorePostingEndPoint(KeychainItem.currentFBIdToken, documentID)
        return rest.request(endpoint) { data in
            try JSONDecoder().decode(Post.self, from: data)
        }
        .retry(when: { [weak self] errorObservable in
            guard let self else { return Observable<Void>.never() }
            return errorObservable.renewToken(with: self.trackTokenService)
        })
        .map { $0.toDomain() }
        .asObservable()
    }
    
    public func updatePostContent(_ store: StoreVO ,_ markDown: String) -> Observable<State<Void>> {
        var store = store
        if store.name.isEmpty {
            store.name = UserManager.shared.profile.nickName
            store.imageURL = UserManager.shared.profile.profileImage
        }
        return writePostContent(markDown, .patch)
            .map { dictionary in
                guard let path = dictionary?["name"] as? String,
                      let markdownPath = path.components(separatedBy: "/").last
                else { return "" }
                return markdownPath
            }
            .withUnretained(self)
            .flatMap { value -> Observable<State<Void>> in
                let (repo, markdownPath) = value
                store.markdownID = markdownPath
                return repo.writePost(store, method: .patch)
                    .andThen(Observable.just(.success(())))
            }
            .retry(when: { [weak self] errorObservable in
                guard let self else { return Observable<Void>.never() }
                return errorObservable.renewToken(with: self.trackTokenService)
            })
            .catchAndReturn(.failure(SendError.unowned))
    }
    
    
    public func upLoadPostingTransaction(_ store: StoreVO, _ markDown: String) -> Observable<State<Void>> {
        self.beginTransaction()
            .map { transactionID -> FireStoreTransaction
                return FireStoreTransaction
                    .postingTransaction(
                        transactionID: transactionID,
                        transcationData: <#T##(markDown: Data?, storeData: Data?)#>)
            }
            .flatMap { transactionId -> Observable<String> in
                guard let markDownData = FireStoreTransaction.createMarkDown(path1, markDown),
                      let postingData =  FireStoreTransaction.createPosting(path2, store) else {
                    return Observable.error(PostingError.postingPublishFail)
                }
                
                let writePayloads = [markDownData, postingData]
                let writesArray = writePayloads.compactMap { try? JSONSerialization.jsonObject(with: $0, options: []) }
                
                let commitBody: [String: Any] = [
                    "writes": writesArray,
                    "transaction": transactionId
                ]
                
                guard let commitData = try? JSONSerialization.data(withJSONObject: commitBody, options: []) else {
                    return Observable.error(PostingError.postingPublishFail)
                }
                
                let commitTransactionEndPoint = CommitTransactionEndPoint(token: firebaseIDToken, transaction: commitData)
                
                return rest.request(
                    commitTransactionEndPoint,
                    operation: { data in
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let _ = json["writeResults"] as? [[String: Any]] {
                            return transactionId
                        } else {
                            throw PostingError.postingPublishFail
                        }
                    }
                )
            }
            .asObservable()
    }
    
    public func upLoadMarkDown(_ markDown: String) -> RxSwift.Observable<[String : Any]?> {
        writePostContent(markDown, nil)
    }
    
    public func upLoadPosting(_ store: StoreVO ,_ markDown: String) -> Observable<State<Void>> {
        var store = store
        
        if store.name.isEmpty {
            store.name = UserManager.shared.profile.nickName
            store.imageURL = UserManager.shared.profile.profileImage
        }
        
        return writePostContent(markDown)
            .map { dictionary in
                guard let path = dictionary?["name"] as? String,
                      let markdownPath = path.components(separatedBy: "/").last
                else { return "" }
                return markdownPath
            }
            .withUnretained(self)
            .flatMap { value -> Observable<State<Void>> in
                let (repo, markdownPath) = value
                store.markdownID = markdownPath
                return repo
                    .writePost(store)
                    .andThen(Observable.just(.success(())))
            }
            .retry(when: { [weak self] errorObservable in
                guard let self else { return Observable<Void>.never() }
                return errorObservable.renewToken(with: self.trackTokenService)
            })
            .catchAndReturn(.failure(SendError.unowned))
    }
}


// MARK: Private Method
extension DefaultPostingRepository {
    
    
    private func beginTransaction() -> Observable<String> {
        let firebaseIDToken = KeychainItem.currentFBIdToken
        let beginTransactionEndPoint = BeginTransactionEndPoint(token: firebaseIDToken)
        return rest.request(
            beginTransactionEndPoint,
            operation: 
                { data in
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let transactionId = json["transaction"] as? String {
                        return transactionId
                    } else {
                        throw PostingError.tranSactionBeginFail
                    }
                }
        )
        .asObservable()
    }
    
    private func writePostContent(_ markDown: String, _ method: RequestMethod? = nil) -> Observable<[String: Any]?> {
        let firebaseIDToken = KeychainItem.currentFBIdToken
        
        let post = Post(markDown)
        
        let endPoint = FireStoreWriteEndPoint(
            token: firebaseIDToken,
            post: post,
            method: method
        )
        
        return rest.request( endPoint, operation: { [weak self] data in
            let string = String(data: data, encoding: .utf8)!
            return try? self?.convertToDictionary(from: string)
        })
        .asObservable()
        .retry(when: { [weak self] errorObservable in
            guard let self else { return Observable<Void>.never() }
            return errorObservable.renewToken(with: self.trackTokenService)
        })
    }
    
    private func writePost(_ store: StoreVO, method: RequestMethod? = nil) -> Completable {
        let firebaseIDToken = KeychainItem.currentFBIdToken
        
        let store = Store(userId: store.userId,
                          title: store.title,
                          name: store.name,
                          date: store.date,
                          description: store.description,
                          markdown: store.markdownID,
                          tags: store.tags)
        
        let endPoint = FireStoreWirteStoreEndPoint(firebaseIDToken, store, method: method)
        
        return rest.post(endPoint)
            .retry(when: { [weak self] errorObservable in
                guard let self else { return Observable<Void>.never() }
                return errorObservable.renewToken(with: self.trackTokenService)
            })
    }
}
