
import UIKit
import RxSwift
import RxCocoa
import Global
import Domain
import SwiftUI
import CommonUI

enum ViewType {
    case preview
    case posting
    case myPosting
    case myPostingTemp
}


enum PostingState {
    case failedToPublish
    case published

    case saving
    case savingFail
    
    case deleted
    case deletedFail
    
    case reported
    case reportedFail
    
    case none
}

enum ActionType: String {
    case temporary = "임시저장"
    case publish   = "출간하기"
    case delete    = "삭제하기"
    case fix       = "수정하기"
    case hide      = "비공개"
    case setting   = "설정"
    case reported = "신고"
    case none
    var string: String {
        self.rawValue
    }
}

private protocol RichTextViewModelType: AnyObject {
    var storeVO:    StoreVO                     { get }
    var viewType:   ViewType                    { get }
    var observable: BehaviorSubject<WriterInfo> { get }
    var usecase:    FirebaseUsecase             { get }
}

public final class RichViewModel: RichTextViewModelType {
    private(set) var storeVO: StoreVO
    private(set) var markDownString: String
    private(set) var viewType: ViewType = .posting
    fileprivate var observable = BehaviorSubject<WriterInfo>(value: .mock)
    fileprivate var usecase: FirebaseUsecase
    private var disposeBag = DisposeBag()
    
    @DynamicPublishWrapper var sendActionWrapper: ActionType
    @DynamicPublishWrapper var postingState: PostingState
    
    init(
        storeVO: StoreVO,
        markDownString: String,
        usecase: FirebaseUsecase,
        viewType: ViewType
    ) {
        self.storeVO = storeVO
        self.markDownString = markDownString
        self.usecase = usecase
        self.viewType = viewType
        binding()
    }
    
    private func binding() {
        $sendActionWrapper
            .subscribe(
                with: self,
                onNext: { vm, value in
                    switch value {
                    case .reported:
                        // usecase
                        print("\(value.string)")
                    case .delete:
                        print("\(value.string)")
                    case .fix:
                        print("\(value.string)")
                    case .hide:
                        print("\(value.string)")
                    case .publish:
                        vm.publishPosting()
                        print("\(value.string)")
                    case .temporary:
                        print("\(value.string)")
                    default:
                        fatalError("not Found Case")
                    }
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func publishPosting() {
        usecase.upLoadPosting(
            store: self.storeVO,
            markdown: self.markDownString
        )
        .subscribe(
            with: self,
            onNext: { vm, state in
                print("state:: \(state)")
                switch state {
                case .success:
                    vm.postingState = .published
                case .failure:
                    vm.postingState = .failedToPublish
                }
            }, onDisposed: { _ in
                print("PUblish state disposed")
            }
        )
        .disposed(by: disposeBag)
        
    }
    
    func transForm() -> Observable<WriterInfo> {
        if viewType == .posting {
            
            return transFormPosting()
            
        } else if viewType == .preview {
            
            return transformPreview()
            
        } else {
            
            return transFormMyPosing() // viewType == .myPosting
            
        }
    }
}


private extension RichTextViewModelType {
    func transFormMyPosing() -> Observable<WriterInfo> {
        DispatchQueue.global().asyncAfter(deadline: .now(), execute: {
            Task {
                [weak self] in
                    guard let self else { return }
                    let storeVO = self.storeVO
                    let cached = ImageCacheClient.shared.getOtherImageFromCache(.init(key: .other(storeVO.userId)))
                    
                    var info = WriterInfo(title: storeVO.title,
                                          writer: storeVO.name,
                                          date: storeVO.date,
                                          image: UIImage(named: "codeStack")!)
                    
                    if let cached {
                        info.image = cached
                        self.observable.onNext(info)
                        return
                    }
                    
                    let stream = self.usecase.fetchOtherUserImagePath(uid: storeVO.userId).values
                    
                    for try await imagePath in stream {
                        let cacheKey = CacheKey(key: .other(storeVO.name))
                        let image = await ImageCacheClient.shared.getOtherImageFromCache(cacheKey, imagePath)
                        info.image = image ?? UIImage(named: "codeStack")!
                    }
                    observable.onNext(info)
            }
        })
        return observable.asObservable()
    }
    
    func transFormPosting() -> Observable<WriterInfo> {
        return observable.asObservable()
    }
    
    func transformPreview() -> Observable<WriterInfo> {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self else { return }
            let storeVO = self.storeVO
            let cached = ImageCacheClient.shared.getMyImageFromCache()
            
            var info = WriterInfo(
                title: storeVO.title,
                writer: storeVO.name,
                date: storeVO.date,
                image: UIImage(named: "codeStack")!
            )
            
            if let cached {
                info.image = cached
            }
            self.observable.onNext(info)
        }
        return observable.asObservable()
    }
}
