//
//  EditorButtonGenerator.swift
//  CommonUIDemo
//
//  Created by hwan on 3/28/25.
//  Copyright © 2025 com.hwan. All rights reserved.
//

import UIKit

enum EditorButtonGenerator {
    indirect enum ButtonType {
        case moveLeft([Command])
        case moveRight([Command])
        case done(Command)
        case tap(Command)
        case details
    }
    
    static func layoutConfig(button: UIButton, size: CGFloat = 28) {
        button.tintColor = .whiteGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: size).isActive = true
        button.heightAnchor.constraint(equalToConstant: size).isActive = true
    }
    
    static func generate(type: ButtonType) -> UIButton {
        switch type {
        case .moveLeft(let commands):
            let moveLeftButton = UIButton(type: .system)
            moveLeftButton.setImage(UIImage(systemName: "arrowshape.backward"), for: .normal)
            layoutConfig(button: moveLeftButton, size: 30)
            
            for command in commands {
                moveLeftButton.addAction(command.asAction(), for: command.controlType)
            }
            
            return moveLeftButton
            
        case .moveRight(let commands):
            let moveRightButton = UIButton(type: .system)
            moveRightButton.setImage(UIImage(systemName: "arrowshape.right"), for: .normal)
            layoutConfig(button: moveRightButton, size: 30)
            
            for command in commands {
                moveRightButton.addAction(command.asAction(), for: command.controlType)
            }
            
            return moveRightButton
            
        case .done(let command):
            let doneButton = UIButton(type: .system)
            doneButton.setImage(UIImage(systemName: "keyboard.chevron.compact.down"), for: .normal)
            layoutConfig(button: doneButton)
            doneButton.addAction(command.asAction(), for: .touchUpInside)
            return doneButton
            
        case .tap(let command):
            let tapButton = UIButton(type: .system)
            tapButton.setImage(UIImage(systemName: "arrow.right.to.line"), for: .normal)
            layoutConfig(button: tapButton)
            tapButton.addAction(command.asAction(), for: .touchUpInside)
            return tapButton
            
        case .details:
            return UIButton(type: .system)
        }
    }
    
}
