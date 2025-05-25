//
//  LoadingButton.swift
//  CodeStack
//
//  Created by 박형환 on 9/23/23.
//

import UIKit

public protocol Loading: UIButton {
    func showLoading()
    func hideLoading()
}

public typealias SendButton = LoadingUIButton

public final class LoadingUIButton: UIButton, Loading {

    public var buttonColor: UIColor = .label
    public var indicatorColor : UIColor = .lightGray
    public var originalButtonText: String?
    
    public var sendButtonHeight: CGFloat = 0
    public var sendButtonWidth: CGFloat = 0
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = indicatorColor
        return activityIndicator
    }()
    
    public convenience init(frame: CGRect, title: String) {
        self.init(frame: frame)
        self.originalButtonText = title
        self.applySubmitAttrubutes(title: title)
        if let font = self.titleLabel?.font {
            sendButtonHeight = title.height(withConstrainedWidth: 150, font: font) + 16
            sendButtonWidth = title.width(withConstrainedHeight: 166, font: font) + 40
        }
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
    }
    
    /// Send Button Attribute Setting
    public func applySubmitAttrubutes(title: String) {
        var configuration = UIButton.Configuration.plain()
        configuration.titlePadding = 10
        self.configuration = configuration
        self.setTitle("\(title)", for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        self.tintColor = .label
        self.layer.borderColor = UIColor.sky_blue.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
    }

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
            guard let self else { return }
            self.isEnabled = true
            self.setTitleColor(.label, for: .normal)
            self.tintColor = .label
            self.activityIndicator.stopAnimating()
            self.setTitle(self.originalButtonText, for: .normal) // 타이틀 복원
        })
    }

    private func showSpinning() {
        centerActivityIndicatorInButton()
        activityIndicator.startAnimating()
    }

    private func centerActivityIndicatorInButton() {
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
