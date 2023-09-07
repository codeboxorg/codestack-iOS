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
    }
    
    private var myPageViewModel: MyPageViewModel?
    private var disposeBag = DisposeBag()
//    lazy var output = myPageViewModel?.transform(input: <#T##MyPageViewModel.Input#>)
    
    private func binding() {
        let editEvent = profileView.editProfileEvent()
        
        editEvent
            .withUnretained(self)
            .do(onNext: { vc, _ in
                vc.checkAuthorize()
            })
            .emit(with: self, onNext: { vc , _ in
                
            }).disposed(by: disposeBag)
        
//        profileView.profileBinder.onNext(ProfileView.Profile(imageURL: <#T##String?#>, name: <#T##String#>, rank: <#T##String?#>))
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
//                    self.myImageView.image = image as? UIImage // 5
                }
            }
        } else {
            // TODO: Handle empty results or item provider not being able load UIImage
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
