//
//  StepView.swift
//  CommonUI
//
//  Created by 박형환 on 1/25/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit


struct StepData {
    let isFillImage: Bool
    let isSeparator: Bool
}

// MARK: 보류 
final class StepItemView: UIView {
    
    private let separator: UIView = {
        let view = UIView()
        return view
    }()
    
    private let statusImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    convenience init(frame: CGRect, item: StepData) {
        self.init(frame: frame)
        
        
    }
    
    private func addAutoLayout(item: StepData) {
        self.addSubview(statusImageView)
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        
        setStepImage(completed: item.isFillImage)
        
        NSLayoutConstraint.activate([
            statusImageView.topAnchor.constraint(equalTo: self.topAnchor),
            statusImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            statusImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
        
        if item.isSeparator {
            let view = addStepSeparator()
            self.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func addStepSeparator(color: UIColor = .label) -> UIView {
        let separator = UIView()
        separator.widthAnchor.constraint(equalToConstant: 100).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 2).isActive = true
        separator.backgroundColor = color
        return separator
    }
    
    private func setStepImage(completed: Bool) {
        statusImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        statusImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        statusImageView.tintColor = .systemGreen
        if completed {
            statusImageView.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            statusImageView.image = UIImage(systemName: "circle")
            statusImageView.alpha = 0.5
        }
    }
    
}
