//
//  ProfileImageViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/09.
//

import UIKit


class ProfileImageViewController: UIViewController {
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.tintColor = UIColor.gray
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    static func create(with: UIImage?) -> ProfileImageViewController {
        let profile = ProfileImageViewController()
        profile.imageView.image = with
        return profile
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

