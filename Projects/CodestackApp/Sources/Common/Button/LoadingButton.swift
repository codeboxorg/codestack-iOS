//
//  LoadingButton.swift
//  CodeStack
//
//  Created by 박형환 on 9/23/23.
//

import UIKit

class LoadingUIButton: UIButton {

    var buttonColor: UIColor = .clear
    var indicatorColor : UIColor = .lightGray
    var originalButtonText: String?
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = indicatorColor
        return activityIndicator
    }()

    func showLoading() {
        originalButtonText = self.titleLabel?.text
        self.isEnabled = false
        self.tintColor = .clear
        self.setTitleColor(.clear, for: .normal)
        self.setTitle("", for: .normal)
        showSpinning()
    }

    func hideLoading() {
        DispatchQueue.main.async(execute: { [weak self] in
            if let color = self?.buttonColor {
                self?.tintColor = color
                self?.setTitleColor(color, for: .normal)
            }
            self?.isEnabled = true
            self?.activityIndicator.stopAnimating()
            self?.setTitle(self?.originalButtonText, for: .normal)
        })
    }

    private func showSpinning() {
        self.addSubview(activityIndicator)
        centerActivityIndicatorInButton()
        activityIndicator.startAnimating()
    }

    private func centerActivityIndicatorInButton() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0)
        ])
    }
}
