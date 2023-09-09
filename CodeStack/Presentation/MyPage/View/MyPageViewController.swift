//
//  MyPageViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/05/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import PhotosUI
import Photos
import RxGesture

typealias ProfileImage = UIImage

final class MyPageViewController: UIViewController{
    
    static func create(with dependency: MyPageViewModel) -> MyPageViewController {
        let vc = MyPageViewController()
        vc.myPageViewModel = dependency
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAutoLayout()
        self.view.backgroundColor = UIColor.systemBackground
        binding()
        DispatchQueue.main.asyncAfter(deadline: .now() , execute: {
            self.statusView.circleProgressView.startProgressAnimate()
            self.statusView.settingProgressViewAnimation(0.3, 0.6, 0.9)
        })
        
        //MARK: Notify ViewDidLoad To ViewModel
        //  _viewDidLoad 는 Behavior라서 초기값으로 인해 accept로 값을 보내주면 2번 호출이 되버림 _viewDidLoad.accept(())
        
    }
    
    private var myPageViewModel: MyPageViewModel?
    private var disposeBag = DisposeBag()
    
    private let _viewDidLoad = BehaviorRelay<Void>(value: ())
    private let profileImageValue = PublishRelay<Data>()
    
    lazy var profileEditEvent = profileView.editProfileEvent()
    lazy var output = myPageViewModel?.transform(input:.init(editProfileEvent: profileEditEvent,
                                                             profileImageValue: profileImageValue.asSignal(),
                                                             viewDidLoad: _viewDidLoad.asSignal(onErrorJustReturn: ())))
//                                                             imageLoading: profileView.imageLoadingEvent()) )
    
    private func binding() {
        
        // TODO: Image 413 code, payload가 너무 큰 상황 -> 이미지 리사이즈 필요
        // TODO: Image 401 unAuthorization -> Authorization header의 토큰이 잘못되었음...
        // TODO: statusCode 400 "Bad Request" -> field
        // MARK: ContentDisposition의 name은 서버에서 받는 field 이름으로
        // MARK: "https://api-v2.codestack.co.kr/v1/member/profile" -i -v Success (984ms): Status 200 성공
        
        profileEditEvent
            .emit(with: self, onNext: { vc, _ in
                vc.checkAuthorize()
            }).disposed(by: disposeBag)

        output?.userProfile
            .drive(with: self, onNext: { vc, profile in
                vc.profileView.profileBinder.onNext(profile)
            }).disposed(by: disposeBag)

        
        if let loading = output?.loading.asDriver() {
            profileView.loadingBinding(loading)
        }
        
        profileView.imageView.rx.gesture(.tap())
            .skip(1)
            .asDriver(onErrorJustReturn: .init())
            .drive(with: self, onNext: { vc, value in
                let imageVC = ProfileImageViewController.create(with: vc.profileView.imageView.image)
                imageVC.modalPresentationStyle = .automatic
                vc.present(imageVC, animated: false)
            }).disposed(by: disposeBag)
        
//        // 액티비티 인디케이터
//        viewModel.activated
//            .map { !$0 }
//            .observeOn(MainScheduler.instance)
//            .do(onNext: { [weak self] finished in
//                if finished {
//                    self?.tableView.refreshControl?.endRefreshing()
//                }
//            })
//            .bind(to: activityIndicator.rx.isHidden)
//            .disposed(by: disposeBag)

            
    }
    
    
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let profileView: ProfileView = {
        let view = ProfileView(frame: .zero)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let statusView: StatusView = {
        let view = StatusView(frame: .zero)
        view.layer.cornerRadius = 12
        return view
    }()
}

private extension MyPageViewController {
    func addAutoLayout(){
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        [profileView,statusView].forEach{
            containerView.addSubview($0)
        }
        
        scrollView.snp.makeConstraints{
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(-44)
        }
        
        containerView.snp.makeConstraints{
            $0.top.leading.bottom.trailing.equalToSuperview()
            $0.width.equalTo(self.view.snp.width)
            $0.height.equalTo(500).priority(.low)
        }
        
        profileView.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(250).priority(.low)
        }
        
        statusView.snp.makeConstraints{
            $0.top.equalTo(profileView.snp.bottom).offset(25)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(300).priority(.low)
        }
    }
}


//MARK: - PHPickerViewControllerDelegate
extension MyPageViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) // 1
        
        let itemProvider = results.first?.itemProvider // 2
        
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) { // 3
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in // 4
                DispatchQueue.main.async {
                    // TODO: Image Update
                    if let image = image as? UIImage {
                        let data = image.compress(to: 500)
                        
                        //TODO: Server에 저장하는 이미지의 사이즈가 21Kb 로 저장된다.
                        // AWS 에 이미지 리사이즈 기능이 있는듯?
                        // 일단 캐시 기능만 SQLite로 될지는 잘 모르겠다.?
                        self.profileView.imageView.load(data: data, completion: { _ in
                            
                        })
                        
                        
                        self.profileImageValue.accept(data)
                    }
                }
            }
        } else {
            
            // TODO: Handle empty results or item provider not being able load UIImage
            // TODO: 선택된 이미지 없다고 표시하기
        }
        
    }
}

extension MyPageViewController {
    
    private func imagePicker() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1
            configuration.filter = .images
            let php = PHPickerViewController(configuration: configuration)
            php.delegate = self
            present(php, animated: true)
        }
    }
    
    private func checkAuthorize() {
        let accessLevel: PHAccessLevel = .readWrite
        let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: accessLevel)
        
        switch authorizationStatus {
        case .limited,.authorized:
            Log.debug("limited authorization granted")
            self.imagePicker()
        default:
            //FIXME: Implement handling for all authorizationStatus values
            requestAuthorizePhoto()
        }
    }
    
    private func requestAuthorizePhoto() {
        let requiredAccessLevel: PHAccessLevel = .readWrite
        PHPhotoLibrary.requestAuthorization(for: requiredAccessLevel) { [weak self] authorizationStatus in
            guard let self else { return }
            switch authorizationStatus {
            case .limited:
                self.imagePicker()
            case .authorized:
                self.imagePicker()
            default:
                break
                //FIXME: Implement handling for all authorizationStatus
                print("Unimplemented")
            }
        }
    }
}
