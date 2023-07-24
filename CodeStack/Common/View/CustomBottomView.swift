//
//  CustomBottomView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/22.
//
import UIKit

class CustomBottomView: UIView {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "The end !"
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        return activityIndicator
    }()
    
    deinit{
        print(activityIndicator)
        activityIndicator.stopAnimating()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        self.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
