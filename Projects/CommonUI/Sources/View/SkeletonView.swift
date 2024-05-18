//
//  SkeletonView.swift
//  CommonUI
//
//  Created by 박형환 on 2/1/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit
import SwiftUI


public struct SkeletonUIKit: UIViewRepresentable {
    public typealias UIViewType = WebSkeletonView
    
    public init() {}
    
    public func makeUIView(context: Context) -> WebSkeletonView {
        WebSkeletonView()
    }
    
    static public func dismantleUIView(_ uiView: WebSkeletonView, coordinator: Void) {
        uiView.containerView.removeSkeletonView()
    }
    
    public func updateUIView(_ uiView: WebSkeletonView, context: Context) { 
        uiView.containerView.removeSkeletonView()
    }
}

public final class WebSkeletonView: BaseView {
    let containerView = UIView()
    let profileView = UIView()
    let titleLabel = UIView()
    
    public override func addAutoLayout() {
        self.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    public override func applyAttributes() {
        layer.setNeedsDisplay()
    }
    
    private var skeletonLayers: [CALayer] {
        (0...3).map { _ in
            let layer = CALayer()
            layer.backgroundColor = UIColor.white.cgColor
            layer.cornerRadius = 8
            containerView.layer.addSublayer(layer)
            return layer
        }
    }
    
    private var isUpdate: Bool = false
    private let xPadding: CGFloat = 20
    private lazy var doubleXPadding: CGFloat = xPadding * 2
    
    public override func layerAttributes() {
        if isUpdate { return }
        _ = (0...5).reduce(into: CGFloat(10)) { pos, _ in
            let pos1 = addTitleSkeletonLine(positionY: pos) + 20
            pos = addLabelSkeletonLine(positionY: pos1) + 12
        }
        isUpdate = true
    }
    
    private func addTitleSkeletonLine(positionY: CGFloat) -> CGFloat {
        let width: CGFloat = self.containerView.bounds.width / 3
        let height: CGFloat = 30
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        layer.cornerRadius = 8
        layer.frame = CGRect(x: xPadding, y: positionY, width: width, height: height)
        layer.addSkeletonLayer()
        containerView.layer.addSublayer(layer)
        return height + positionY
    }
    
    private func addLabelSkeletonLine(positionY: CGFloat) -> CGFloat {
        let width: CGFloat = self.containerView.bounds.width
        let height: CGFloat = 16
        return skeletonLayers.reduce(into: positionY) { value, layer in
            let width = width - doubleXPadding - CGFloat((0...100).randomElement()!)
            layer.frame = CGRect(x: xPadding, y: value, width: width, height: height)
            layer.addSkeletonLayer()
            value += (height + 12)
        }
    }
}




