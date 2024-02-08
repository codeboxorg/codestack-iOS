//
//  LoadingButton.swift
//  CodeStack
//
//  Created by 박형환 on 9/23/23.
//

import UIKit

public final class LoadingUIButton: UIButton {

    public var buttonColor: UIColor = .clear
    public var indicatorColor : UIColor = .lightGray
    public var originalButtonText: String?
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = indicatorColor
        return activityIndicator
    }()

    public func showLoading() {
        originalButtonText = self.titleLabel?.text
        self.isEnabled = false
        self.tintColor = .clear
        self.setTitleColor(.clear, for: .normal)
        self.setTitle("", for: .normal)
        showSpinning()
    }

    public func hideLoading() {
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
    
    @objc public func buttonTest(_ sender: UIButton) {
        self.showLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.hideLoading()
        }
    }
}


//import SwiftUI
//@available(iOS 17.0, *)
//#Preview {
//    var sendButtonHeight: CGFloat = 150
//    var sendButtonWidth: CGFloat = 28
//    var button = LoadingUIButton()
//    button.setTitleColor(.white, for: .normal)
//    button.tintColor = .sky_blue
//    button.buttonColor = .sky_blue
//    button.addTarget(button, action: #selector(button.buttonTest(_:)), for: .touchUpInside)
//    button.originalButtonText = "안녕하세요"
//    button.applySubmitAttrubutes()
//    if let font = button.titleLabel?.font {
//        sendButtonHeight = button.originalButtonText!.height(withConstrainedWidth: 150, font: font) + 16
//        sendButtonWidth = button.originalButtonText!.width(withConstrainedHeight: sendButtonHeight + 16, font: font) + 40
//    }
//    NSLayoutConstraint.activate([
//        button.widthAnchor.constraint(equalToConstant: sendButtonWidth),
//        button.heightAnchor.constraint(equalToConstant: sendButtonHeight)
//    ])
//    return button
//}
