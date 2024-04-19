//
//  PhotoPickerView.swift
//  CommonUI
//
//  Created by 박형환 on 2/25/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import PhotosUI

public final class PhotoPickerViewController: BaseViewController, PHPickerViewControllerDelegate {
    
    private var profileImageView: UIImageView = UIImageView()
    
    public var action: ((NSItemProviderReading?, Error?) -> Void)?
    
    public override func applyAttributes() {
        
    }
    
    public override func addAutoLayout() {
        
    }
    
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) // 1
        let itemProvider = results.first?.itemProvider // 2
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) { // 3
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in // 4
                self?.action?(image, error)
            }
        } else {
            // TODO: Handle empty results or item provider not being able load UIImage
            // TODO: 선택된 이미지 없다고 표시하기
        }
    }
    
    public func checkAuthorize(_ viewController: UIViewController) {
        let accessLevel: PHAccessLevel = .readWrite
        let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: accessLevel)
        
        switch authorizationStatus {
        case .limited,.authorized:
            self.imagePicker(viewController)
        default:
            //FIXME: Implement handling for all authorizationStatus values
            requestAuthorizePhoto(viewController)
        }
    }
    
    private func imagePicker(_ viewController: UIViewController) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1
            configuration.filter = .images
            let php = PHPickerViewController(configuration: configuration)
            php.delegate = self
            viewController.present(php, animated: true)
        }
    }
    
    private func requestAuthorizePhoto(_ viewController: UIViewController) {
        let requiredAccessLevel: PHAccessLevel = .readWrite
        PHPhotoLibrary.requestAuthorization(for: requiredAccessLevel) { [weak self] authorizationStatus in
            guard let self else { return }
            switch authorizationStatus {
            case .limited:
                self.imagePicker(viewController)
            case .authorized:
                self.imagePicker(viewController)
            default:
                break
                //FIXME: Implement handling for all authorizationStatus
                // print("Unimplemented")
            }
        }
    }
    
}
